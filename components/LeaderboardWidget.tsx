'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaTrophy, FaMedal, FaCrown, FaChevronRight, FaStar, FaGamepad } from 'react-icons/fa';
import Link from 'next/link';

type LeaderboardPlayer = {
  username: string;
  minecraftUsername?: string;
  loyaltyLifetimePoints?: number;
  avatar?: string;
};

type LeaderboardTab = 'loyalty' | 'votes' | 'playtime';

const rankColors = [
  'from-yellow-400 to-amber-500',   // #1 Gold
  'from-gray-300 to-gray-400',       // #2 Silver
  'from-amber-600 to-amber-700',     // #3 Bronze
];

const rankBorderColors = [
  'border-yellow-400/40',
  'border-gray-300/30',
  'border-amber-600/30',
];

const rankIcons = [
  <FaCrown key="crown" className="text-yellow-400" />,
  <FaMedal key="silver" className="text-gray-300" />,
  <FaMedal key="bronze" className="text-amber-600" />,
];

export default function LeaderboardWidget() {
  const [players, setPlayers] = useState<LeaderboardPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<LeaderboardTab>('loyalty');
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  useEffect(() => {
    fetch('/api/leaderboard')
      .then(res => res.json())
      .then(data => {
        if (Array.isArray(data) && data.length > 0) {
          setPlayers(data);
        } else {
          setPlayers([
            { username: 'Notch', loyaltyLifetimePoints: 1420 },
            { username: 'Jeb_', loyaltyLifetimePoints: 890 },
            { username: 'Dinnerbone', loyaltyLifetimePoints: 734 },
            { username: 'Herobrine', loyaltyLifetimePoints: 666 },
            { username: 'Steve', loyaltyLifetimePoints: 520 },
            { username: 'Alex', loyaltyLifetimePoints: 390 },
            { username: 'Dream', loyaltyLifetimePoints: 285 },
            { username: 'Technoblade', loyaltyLifetimePoints: 210 },
            { username: 'Philza', loyaltyLifetimePoints: 180 },
            { username: 'TommyInnit', loyaltyLifetimePoints: 120 },
          ]);
        }
      })
      .catch(() => {
        setPlayers([
          { username: 'Notch', loyaltyLifetimePoints: 1420 },
          { username: 'Jeb_', loyaltyLifetimePoints: 890 },
          { username: 'Dinnerbone', loyaltyLifetimePoints: 734 },
          { username: 'Herobrine', loyaltyLifetimePoints: 666 },
          { username: 'Steve', loyaltyLifetimePoints: 520 },
        ]);
      })
      .finally(() => setLoading(false));
  }, []);

  const tabs: { id: LeaderboardTab; label: string; icon: React.ReactNode }[] = [
    { id: 'loyalty', label: 'Loyalty', icon: <FaStar className="text-minecraft-gold" /> },
    { id: 'votes', label: 'Votes', icon: <FaTrophy className="text-minecraft-grass" /> },
    { id: 'playtime', label: 'Playtime', icon: <FaGamepad className="text-minecraft-diamond" /> },
  ];

  const maxPoints = Math.max(...players.map(p => p.loyaltyLifetimePoints || 0), 1);

  return (
    <div className="relative overflow-hidden bg-gray-900/60 backdrop-blur-xl border border-white/10 rounded-2xl h-full flex flex-col">
      {/* Decorative Glows */}
      <div className="absolute -top-20 -left-20 w-40 h-40 bg-minecraft-gold/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-20 -right-20 w-40 h-40 bg-minecraft-diamond/8 rounded-full blur-3xl pointer-events-none" />

      {/* Header */}
      <div className="relative z-10 p-6 pb-0">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="relative">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-minecraft-gold/30 to-minecraft-gold/10 border border-minecraft-gold/20 flex items-center justify-center">
                <FaTrophy className="text-minecraft-gold text-lg" />
              </div>
              <div className="absolute -top-1 -right-1 w-3 h-3 bg-minecraft-grass rounded-full border-2 border-gray-900 animate-pulse" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white tracking-tight">Leaderboard</h2>
              <p className="text-xs text-gray-500">Top players this season</p>
            </div>
          </div>
          <Link
            href="/vote"
            className="flex items-center gap-1 text-xs font-semibold text-minecraft-grass hover:text-minecraft-grass/80 transition-colors group"
          >
            <span>View all</span>
            <FaChevronRight className="text-[10px] group-hover:translate-x-0.5 transition-transform" />
          </Link>
        </div>

        {/* Tab Switcher */}
        <div className="flex gap-1 p-1 bg-black/30 rounded-xl border border-white/5">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex-1 flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg text-xs font-semibold transition-all duration-300 ${
                activeTab === tab.id
                  ? 'bg-white/10 text-white border border-white/10 shadow-lg shadow-black/20'
                  : 'text-gray-500 hover:text-gray-300 border border-transparent'
              }`}
            >
              {tab.icon}
              <span>{tab.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Player List */}
      <div className="relative z-10 flex-1 p-6 pt-4 space-y-2 overflow-y-auto max-h-[500px] custom-scrollbar">
        {loading ? (
          <div className="space-y-2 animate-pulse">
            {[1, 2, 3, 4, 5].map(i => (
              <div key={i} className="h-14 bg-white/5 rounded-xl border border-white/5" />
            ))}
          </div>
        ) : (
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
              className="space-y-2"
            >
              {players.map((player, i) => {
                const isTop3 = i < 3;
                const points = player.loyaltyLifetimePoints || 0;
                const barWidth = (points / maxPoints) * 100;

                return (
                  <motion.div
                    key={`${player.username}-${i}`}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: i * 0.05, duration: 0.4 }}
                    onMouseEnter={() => setHoveredIndex(i)}
                    onMouseLeave={() => setHoveredIndex(null)}
                    className={`relative flex items-center justify-between p-3 rounded-xl border transition-all duration-300 group cursor-default overflow-hidden ${
                      isTop3
                        ? `${rankBorderColors[i]} bg-gradient-to-r from-black/40 to-transparent hover:from-black/60`
                        : 'border-white/5 bg-black/20 hover:bg-black/40 hover:border-white/10'
                    }`}
                  >
                    {/* Progress Bar Background */}
                    <motion.div
                      className={`absolute inset-y-0 left-0 rounded-xl opacity-[0.06] ${
                        isTop3 ? `bg-gradient-to-r ${rankColors[i]}` : 'bg-white'
                      }`}
                      initial={{ width: 0 }}
                      animate={{ width: `${barWidth}%` }}
                      transition={{ delay: i * 0.08 + 0.3, duration: 0.8, ease: 'easeOut' }}
                    />

                    <div className="flex items-center gap-3 relative z-10">
                      {/* Rank */}
                      <div className={`w-7 flex justify-center ${isTop3 ? '' : ''}`}>
                        {isTop3 ? (
                          <span className="text-lg">{rankIcons[i]}</span>
                        ) : (
                          <span className="text-sm font-bold text-gray-600 tabular-nums">
                            #{i + 1}
                          </span>
                        )}
                      </div>

                      {/* Avatar */}
                      <div className="relative">
                        <img
                          src={`https://minotar.net/helm/${player.minecraftUsername || player.username}/32.png`}
                          alt={player.minecraftUsername || player.username}
                          className={`w-8 h-8 rounded-lg transition-transform duration-300 ${
                            hoveredIndex === i ? 'scale-110' : ''
                          }`}
                          onError={(e) => {
                            (e.target as HTMLImageElement).src = `https://minotar.net/helm/Steve/32.png`;
                          }}
                        />
                        {isTop3 && (
                          <div className={`absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-gray-900 bg-gradient-to-r ${rankColors[i]}`} />
                        )}
                      </div>

                      {/* Name */}
                      <span className={`font-semibold truncate max-w-[120px] ${
                        isTop3 ? 'text-white' : 'text-gray-300'
                      }`}>
                        {player.minecraftUsername || player.username}
                      </span>
                    </div>

                    {/* Points */}
                    <div className="relative z-10 flex items-center gap-2">
                      <div className={`font-mono text-sm font-bold tabular-nums ${
                        i === 0
                          ? 'text-yellow-400'
                          : i === 1
                            ? 'text-gray-300'
                            : i === 2
                              ? 'text-amber-500'
                              : 'text-gray-500'
                      }`}>
                        {points.toLocaleString()}
                      </div>
                      <span className="text-[10px] text-gray-600 font-semibold uppercase tracking-wider">
                        pts
                      </span>
                    </div>
                  </motion.div>
                );
              })}
            </motion.div>
          </AnimatePresence>
        )}
      </div>

      {/* Footer Gradient */}
      <div className="relative z-10 px-6 py-4 border-t border-white/5 bg-gradient-to-t from-gray-900/80 to-transparent">
        <div className="flex items-center justify-between">
          <p className="text-xs text-gray-500">
            Updated every 30 seconds
          </p>
          <div className="flex items-center gap-1">
            <div className="w-1.5 h-1.5 rounded-full bg-minecraft-grass animate-pulse" />
            <span className="text-xs text-minecraft-grass font-medium">Live</span>
          </div>
        </div>
      </div>
    </div>
  );
}
