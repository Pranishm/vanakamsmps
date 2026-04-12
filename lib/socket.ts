/**
 * Socket.io Client Singleton
 * ──────────────────────────
 * Shared across all React components.
 * Connects to the custom server with `clientType: 'web'`.
 */

'use client';

import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    socket = io({
      // When running on the same origin, no URL needed.
      // Socket.io auto-connects to window.location.origin.
      query: { clientType: 'web' },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: Infinity,
    });
  }
  return socket;
}

export default getSocket;
