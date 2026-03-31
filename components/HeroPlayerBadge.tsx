'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

export default function HeroPlayerBadge({ host, port }: { host: string; port: number }) {
  const [players, setPlayers] = useState<number | null>(null);

  useEffect(() => {
    fetch(`/api/server/status?host=${encodeURIComponent(host)}&port=${port}`)
      .then(res => res.json())
      .then(data => {
        if (data && data.online) {
          setPlayers(data.players?.online || 0);
        }
      })
      .catch(() => {});
  }, [host, port]);

  if (players === null) return null;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      className="inline-flex mx-auto mb-6 items-center gap-2 rounded-full border border-green-500/30 bg-green-500/10 px-4 py-1.5 text-sm font-medium text-green-400 backdrop-blur-md"
    >
      <span className="relative flex h-2 w-2">
        <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75"></span>
        <span className="relative inline-flex h-2 w-2 rounded-full bg-green-500"></span>
      </span>
      {players} players online
    </motion.div>
  );
}
