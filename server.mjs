/**
 * Custom Socket.io + Next.js Server
 * ──────────────────────────────────
 * This wraps the standard Next.js HTTP server and adds Socket.io
 * for real-time sync between React admin panel ↔ Flutter app.
 *
 * Features:
 *   • Real-time settings broadcast (React ↔ Flutter)
 *   • Online player tracking (socket connections)
 *   • Server health endpoint for Flutter status widget
 *
 * Usage:
 *   DEV  → node server.mjs
 *   PROD → NODE_ENV=production node server.mjs
 */

import { createServer } from 'http';
import { parse } from 'url';
import next from 'next';
import { Server as SocketIOServer } from 'socket.io';
import process from 'process';
import os from 'os';

// ── Config ──────────────────────────────────────────────────────
const dev = process.env.NODE_ENV !== 'production';
const hostname = process.env.HOST || (dev ? '0.0.0.0' : '0.0.0.0');
const port = parseInt(process.env.PORT || '3000', 10);

// ── Next.js ─────────────────────────────────────────────────────
const app = next({ dev, hostname, port });
const handle = app.getRequestHandler();

// ── ANSI Colors (reuse your dev.mjs style) ──────────────────────
const ansi = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  cyan: '\x1b[36m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m',
  red: '\x1b[31m',
  magenta: '\x1b[35m',
};

function c(text, code) {
  return `${code}${text}${ansi.reset}`;
}

function getNetworkIPv4() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name] || []) {
      if (net.family !== 'IPv4' || net.internal) continue;
      return net.address;
    }
  }
  return null;
}

// ── State ───────────────────────────────────────────────────────
const connectedClients = new Map(); // socketId → { type, connectedAt }
let cachedSettings = null;          // in-memory mirror for fast REST

function getOnlineCount(type) {
  if (!type) return connectedClients.size;
  let count = 0;
  for (const info of connectedClients.values()) {
    if (info.type === type) count++;
  }
  return count;
}

// ── Boot ────────────────────────────────────────────────────────
app.prepare().then(() => {
  const httpServer = createServer((req, res) => {
    // ── Lightweight health check (no Next.js overhead) ──────────
    if (req.url === '/api/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status: 'ok',
        uptime: process.uptime(),
        timestamp: Date.now(),
      }));
      return;
    }

    // ── Online players REST endpoint ─────────────────────────────
    if (req.url === '/api/online-players') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        total: connectedClients.size,
        web: getOnlineCount('web'),
        flutter: getOnlineCount('flutter'),
        other: getOnlineCount('other'),
      }));
      return;
    }

    // ── Cached settings for Flutter initial fetch ────────────────
    if (req.url === '/api/settings/public' && req.method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(cachedSettings || {}));
      return;
    }

    // ── All other routes → Next.js ───────────────────────────────
    const parsedUrl = parse(req.url, true);
    handle(req, res, parsedUrl);
  });

  // ── Socket.io Server ──────────────────────────────────────────
  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: '*',               // Flutter + Web + dev
      methods: ['GET', 'POST'],
    },
    pingInterval: 25000,
    pingTimeout: 60000,
  });

  // Expose io to Next.js API routes via globalThis
  globalThis.__io = io;
  globalThis.__connectedClients = connectedClients;

  io.on('connection', (socket) => {
    // Clients should send their type on connect: 'web' | 'flutter'
    const clientType = socket.handshake.query.clientType || 'other';

    connectedClients.set(socket.id, {
      type: clientType,
      connectedAt: new Date().toISOString(),
    });

    console.log(
      `${c('⚡', ansi.green)} ${c('connected', ansi.bold)} ${socket.id} ` +
      `(${c(clientType, ansi.cyan)}) — ` +
      `${c(connectedClients.size + ' online', ansi.yellow)}`
    );

    // Broadcast updated player count
    io.emit('player_count_update', {
      total: connectedClients.size,
      web: getOnlineCount('web'),
      flutter: getOnlineCount('flutter'),
    });

    // ── Settings Sync ─────────────────────────────────────────
    // When a client (React or Flutter) updates a setting:
    socket.on('update_setting', (data) => {
      console.log(
        `${c('⚙️', ansi.magenta)} ${c('setting_update', ansi.bold)} from ${socket.id}: ` +
        JSON.stringify(data).slice(0, 200)
      );

      // Update in-memory cache
      if (data && typeof data === 'object') {
        cachedSettings = { ...cachedSettings, ...data };
      }

      // Broadcast to EVERYONE ELSE (React ↔ Flutter)
      socket.broadcast.emit('setting_changed', {
        ...data,
        updatedBy: clientType,
        updatedAt: new Date().toISOString(),
      });
    });

    // ── Request full settings (Flutter on first load) ─────────
    socket.on('request_settings', () => {
      socket.emit('settings_snapshot', cachedSettings || {});
    });

    // ── Disconnect ────────────────────────────────────────────
    socket.on('disconnect', (reason) => {
      connectedClients.delete(socket.id);

      console.log(
        `${c('🔌', ansi.red)} ${c('disconnected', ansi.dim)} ${socket.id} ` +
        `(${reason}) — ${c(connectedClients.size + ' online', ansi.yellow)}`
      );

      io.emit('player_count_update', {
        total: connectedClients.size,
        web: getOnlineCount('web'),
        flutter: getOnlineCount('flutter'),
      });
    });
  });

  // ── Start ─────────────────────────────────────────────────────
  httpServer.listen(port, hostname, () => {
    const netIp = getNetworkIPv4();
    const mode = dev ? 'development' : 'production';

    console.log('');
    console.log(c('┌──────────────────────────────────────────┐', ansi.cyan));
    console.log(c('│', ansi.cyan) + ` ${c('VANAKAMSMPs', ansi.bold)} — ${c('Sync Bridge', ansi.magenta)}            ${c('│', ansi.cyan)}`);
    console.log(c('│', ansi.cyan) + c('──────────────────────────────────────────', ansi.gray) + c('│', ansi.cyan));
    console.log(c('│', ansi.cyan) + ` ${c('Mode:    ', ansi.gray)} ${c(mode, ansi.green)}                       ${c('│', ansi.cyan)}`);
    console.log(c('│', ansi.cyan) + ` ${c('Local:   ', ansi.gray)} ${c(`http://${hostname}:${port}`, ansi.green)}         ${c('│', ansi.cyan)}`);
    if (netIp) {
      console.log(c('│', ansi.cyan) + ` ${c('Network: ', ansi.gray)} ${c(`http://${netIp}:${port}`, ansi.green)}     ${c('│', ansi.cyan)}`);
    }
    console.log(c('│', ansi.cyan) + ` ${c('Socket:  ', ansi.gray)} ${c('✓ Socket.io active', ansi.green)}              ${c('│', ansi.cyan)}`);
    console.log(c('│', ansi.cyan) + ` ${c('Health:  ', ansi.gray)} ${c('/api/health', ansi.yellow)}                     ${c('│', ansi.cyan)}`);
    console.log(c('│', ansi.cyan) + ` ${c('Players: ', ansi.gray)} ${c('/api/online-players', ansi.yellow)}              ${c('│', ansi.cyan)}`);
    console.log(c('└──────────────────────────────────────────┘', ansi.cyan));
    console.log('');
  });
});

// ── Graceful shutdown ───────────────────────────────────────────
function shutdown(signal) {
  console.log(`\n${c(`Received ${signal}, shutting down…`, ansi.yellow)}`);
  process.exit(0);
}
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
