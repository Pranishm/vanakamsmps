'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import { FaServer, FaUsers, FaCopy, FaCheck, FaDesktop } from 'react-icons/fa';
import { type ServerStatus } from '@/lib/minecraft';
import { t } from '@/lib/i18n';
import { useClientLang } from '@/lib/useClientLang';

interface ServerStatusWidgetProps {
  host: string;
  port?: number;
}

const ServerStatusWidget = ({ host, port = 25565 }: ServerStatusWidgetProps) => {
  const lang = useClientLang();
  const [status, setStatus] = useState<ServerStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  const portNumber = Number.isFinite(Number(port)) ? Number(port) : 25565;
  const serverAddress = `${host}:${portNumber}`;
  const displayAddress = host;

  useEffect(() => {
    const fetchStatus = async () => {
      setLoading(true);
      try {
        const res = await fetch(`/api/server/status?host=${encodeURIComponent(host)}&port=${portNumber}`, {
          cache: 'no-store',
        });
        const data = (await res.json().catch(() => null)) as ServerStatus | null;
        if (res.ok && data) {
          setStatus(data);
        } else {
          setStatus({ online: false, players: { online: 0, max: 0 } });
        }
      } catch {
        setStatus({ online: false, players: { online: 0, max: 0 } });
      }
      setLoading(false);
    };

    fetchStatus();
    const interval = setInterval(fetchStatus, 10000);

    return () => clearInterval(interval);
  }, [host, portNumber]);

  const copyIP = () => {
    try {
      navigator.clipboard.writeText(displayAddress);
    } catch {
      // ignore
    }
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (loading) {
    return (
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="relative overflow-hidden bg-gray-900/50 backdrop-blur-xl border border-gray-800 rounded-lg p-6"
      >
        <div className="animate-pulse">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-3 h-3 rounded-full bg-gray-700" />
            <div className="h-4 bg-gray-700 rounded w-24" />
          </div>
          <div className="h-16 bg-gray-800/50 rounded-md mb-3" />
          <div className="grid grid-cols-2 gap-3">
            <div className="h-16 bg-gray-800/50 rounded-lg" />
            <div className="h-16 bg-gray-800/50 rounded-lg" />
          </div>
        </div>
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] }}
      className="relative overflow-hidden bg-gray-900/50 backdrop-blur-xl border border-gray-800 rounded-lg p-6"
    >
      {/* Decorative glows */}
      {status?.online && (
        <>
          <div className="absolute -top-12 -left-12 w-24 h-24 bg-minecraft-grass/10 rounded-full blur-2xl pointer-events-none" />
          <div className="absolute -bottom-12 -right-12 w-24 h-24 bg-minecraft-diamond/8 rounded-full blur-2xl pointer-events-none" />
        </>
      )}

      {/* Status Header */}
      <div className="flex items-center justify-between mb-4 relative z-10">
        <div className="flex items-center space-x-3">
          <div className="relative">
            <div className={`w-3 h-3 rounded-full ${status?.online ? 'bg-green-500' : 'bg-red-500'}`} />
            {status?.online && (
              <div className="absolute inset-0 w-3 h-3 rounded-full bg-green-500 animate-ping opacity-50" />
            )}
          </div>
          <span className="text-white font-medium">
            {status?.online ? t(lang, 'serverStatus.online') : t(lang, 'serverStatus.offline')}
          </span>
        </div>
        {status?.online && (
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="flex items-center gap-1"
          >
            <div className="w-1.5 h-1.5 rounded-full bg-minecraft-grass animate-pulse" />
            <span className="text-xs text-minecraft-grass font-medium">Live</span>
          </motion.div>
        )}
      </div>

      {/* Server Info Card */}
      <div className="flex items-center justify-between gap-3 bg-black/30 rounded-md p-3 mb-3 relative z-10">
        <div className="flex items-start gap-3 min-w-0">
          <div className="relative h-10 w-10 rounded-md overflow-hidden shrink-0">
            {status?.favicon ? (
              <Image src={status.favicon} alt="" fill sizes="40px" className="object-cover" />
            ) : (
              <div className="h-full w-full grid place-items-center text-minecraft-grass bg-minecraft-grass/10 rounded-md">
                <FaServer />
              </div>
            )}
          </div>

          <div className="min-w-0">
            <div className="flex items-center gap-2 mb-0.5">
              <span className="text-xs font-bold uppercase tracking-wider text-minecraft-grass">Java Edition</span>
              <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-minecraft-grass/20 text-minecraft-grass border border-minecraft-grass/30">
                <FaDesktop className="mr-1 text-[8px]" />
                PC Only
              </span>
            </div>
            <div className="text-white font-mono break-all text-sm">{displayAddress}</div>
            <div className="text-sm text-gray-400 mt-1 leading-snug break-words">
              {String(status?.motd || '').trim() || 'No server message.'}
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          {status?.online ? (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="flex items-center gap-2 text-minecraft-grass px-3 py-2 rounded-md bg-minecraft-grass/10 border border-minecraft-grass/20"
            >
              <FaUsers />
              <span className="font-bold tabular-nums">
                {status.players.online}/{status.players.max}
              </span>
            </motion.div>
          ) : null}

          <button
            type="button"
            onClick={copyIP}
            aria-label={copied ? 'IP copied' : 'Copy IP'}
            title={copied ? 'IP copied' : 'Copy IP'}
            className="inline-flex items-center justify-center p-2 rounded-md bg-minecraft-grass/20 text-minecraft-grass hover:bg-minecraft-grass/30 transition-all duration-200 hover:scale-105 active:scale-95"
          >
            <AnimatePresence mode="wait">
              {copied ? (
                <motion.span
                  key="check"
                  initial={{ scale: 0, rotate: -180 }}
                  animate={{ scale: 1, rotate: 0 }}
                  exit={{ scale: 0 }}
                >
                  <FaCheck />
                </motion.span>
              ) : (
                <motion.span
                  key="copy"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  exit={{ scale: 0 }}
                >
                  <FaCopy />
                </motion.span>
              )}
            </AnimatePresence>
          </button>
        </div>
      </div>

      {/* Stats Row */}
      {status?.online && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="grid grid-cols-2 gap-3 mt-4 mb-2 relative z-10"
        >
          <div className="bg-gray-950/50 rounded-lg p-3 border border-gray-800 flex flex-col items-center justify-center group hover:border-minecraft-grass/20 transition-colors">
            <span className="text-gray-400 text-xs uppercase font-bold tracking-wider mb-1">Server TPS</span>
            <span className="text-minecraft-grass font-bold font-mono">20.0 <span className="text-gray-500 text-xs">/ 20.0</span></span>
          </div>
          <div className="bg-gray-950/50 rounded-lg p-3 border border-gray-800 flex flex-col items-center justify-center group hover:border-minecraft-diamond/20 transition-colors">
            <span className="text-gray-400 text-xs uppercase font-bold tracking-wider mb-1">Uptime</span>
            <span className="text-minecraft-diamond font-bold font-mono">99.9<span className="text-gray-500 text-xs">%</span></span>
          </div>
        </motion.div>
      )}

      {status?.version && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-sm text-gray-500 mt-3 flex items-center gap-2 relative z-10"
        >
          <div className="px-2 py-1 bg-gray-800 rounded text-xs font-mono">{status.version}</div>
          <span>Supported Client Version</span>
        </motion.div>
      )}
    </motion.div>
  );
};

export default ServerStatusWidget;
