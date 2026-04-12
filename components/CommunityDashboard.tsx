'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { FaHistory, FaGem, FaRocket, FaBolt, FaStar, FaArrowRight } from 'react-icons/fa';
import Link from 'next/link';
import LeaderboardWidget from './LeaderboardWidget';

export default function CommunityDashboard() {
  return (
    <section className="mx-auto max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
      {/* Section Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5 }}
        className="mb-10 text-center"
      >
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-minecraft-gold/10 border border-minecraft-gold/20 text-minecraft-gold text-sm font-semibold mb-4">
          <FaStar className="text-xs" />
          <span>Community Hub</span>
        </div>
        <h2 className="text-3xl font-bold text-gray-900 dark:text-white sm:text-4xl md:text-5xl mb-3">
          Live Dashboard
        </h2>
        <p className="text-base text-gray-600 dark:text-gray-400 sm:text-lg max-w-2xl mx-auto">
          Track leaderboards, patch notes, and featured ranks in real-time.
        </p>
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Live Leaderboard - Uses the new dedicated widget */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
        >
          <LeaderboardWidget />
        </motion.div>

        {/* Changelog & Updates */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.15, duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
        >
          <div className="relative overflow-hidden bg-gray-900/60 backdrop-blur-xl border border-white/10 rounded-2xl p-6 h-full flex flex-col">
            {/* Decorative glow */}
            <div className="absolute -top-16 -right-16 w-32 h-32 bg-minecraft-grass/10 rounded-full blur-3xl pointer-events-none" />

            <div className="flex items-center justify-between mb-6 relative z-10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-minecraft-grass/30 to-minecraft-grass/10 border border-minecraft-grass/20 flex items-center justify-center">
                  <FaHistory className="text-minecraft-grass text-lg" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-white tracking-tight">Patch Notes</h2>
                  <p className="text-xs text-gray-500">Latest updates</p>
                </div>
              </div>
              <Link href="/news" className="flex items-center gap-1 text-xs font-semibold text-minecraft-grass hover:text-minecraft-grass/80 transition-colors group">
                <span>All notes</span>
                <FaArrowRight className="text-[10px] group-hover:translate-x-0.5 transition-transform" />
              </Link>
            </div>

            <div className="flex-1 space-y-5 relative z-10">
              {/* Latest patch */}
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.2 }}
                className="relative pl-6 border-l-2 border-minecraft-grass/30 pb-4"
              >
                <div className="absolute w-3 h-3 bg-minecraft-grass rounded-full -left-[7px] top-1 shadow-[0_0_8px_rgba(123,192,67,0.5)]" />
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs text-minecraft-grass font-bold">v2.1.0</span>
                  <span className="px-1.5 py-0.5 rounded text-[10px] font-bold bg-minecraft-grass/20 text-minecraft-grass border border-minecraft-grass/30">NEW</span>
                </div>
                <h3 className="text-white font-bold text-base mb-2">The Economy Update</h3>
                <p className="text-gray-400 text-sm leading-relaxed">
                  Massive overhaul to the shop prices, new daily login rewards, and fixed the dupe glitch in Skyblock.
                </p>
                <div className="flex flex-wrap gap-2 mt-3">
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-blue-500/10 text-blue-400 border border-blue-500/20">Economy</span>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-red-500/10 text-red-400 border border-red-500/20">Bugfix</span>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-green-500/10 text-green-400 border border-green-500/20">Feature</span>
                </div>
              </motion.div>

              {/* Previous patch */}
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.35 }}
                className="relative pl-6 border-l-2 border-gray-700 pb-4"
              >
                <div className="absolute w-3 h-3 bg-gray-600 rounded-full -left-[7px] top-1" />
                <div className="text-xs text-gray-500 font-bold mb-1">v2.0.5 • Last Week</div>
                <h3 className="text-gray-300 font-bold text-base mb-2">Performance Patch</h3>
                <p className="text-gray-500 text-sm leading-relaxed">
                  Upgraded server RAM to 64GB DDR5 and optimized redstone tick calculations.
                </p>
              </motion.div>

              {/* Older patch */}
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.5 }}
                className="relative pl-6 border-l-2 border-gray-800"
              >
                <div className="absolute w-3 h-3 bg-gray-700 rounded-full -left-[7px] top-1" />
                <div className="text-xs text-gray-600 font-bold mb-1">v2.0.0 • 2 Weeks Ago</div>
                <h3 className="text-gray-400 font-bold text-base mb-1">Season 2 Launch</h3>
                <p className="text-gray-600 text-sm leading-relaxed">
                  Fresh world reset, new spawn, and custom enchantments system.
                </p>
              </motion.div>
            </div>
          </div>
        </motion.div>

        {/* Ranks Showcase */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.3, duration: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
        >
          <div className="relative overflow-hidden bg-gradient-to-br from-gray-900 to-gray-950 border border-minecraft-diamond/20 rounded-2xl p-6 h-full flex flex-col">
            {/* Decorative glows */}
            <div className="absolute top-0 right-0 w-40 h-40 bg-minecraft-diamond/10 rounded-full blur-3xl pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-32 h-32 bg-purple-500/8 rounded-full blur-3xl pointer-events-none" />

            <div className="flex items-center gap-3 mb-6 relative z-10">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-minecraft-diamond/30 to-minecraft-diamond/10 border border-minecraft-diamond/20 flex items-center justify-center">
                <FaGem className="text-minecraft-diamond text-lg" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-white tracking-tight">Featured Rank</h2>
                <p className="text-xs text-gray-500">Limited time offer</p>
              </div>
            </div>

            <div className="flex-1 flex flex-col justify-center items-center text-center relative z-10 py-4">
              <motion.div
                animate={{ y: [0, -8, 0] }}
                transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
                className="text-6xl mb-6 drop-shadow-[0_0_20px_rgba(71,209,232,0.3)]"
              >
                👑
              </motion.div>
              <h3 className="text-sm font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-300 via-amber-400 to-yellow-500 mb-1 font-[family-name:var(--font-press-start)] tracking-widest">
                MVP+ RANK
              </h3>
              <div className="flex items-center gap-2 mt-2 mb-4">
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-minecraft-diamond/20 text-minecraft-diamond border border-minecraft-diamond/30">/fly</span>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-yellow-500/20 text-yellow-400 border border-yellow-500/30">5x Keys</span>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-500/20 text-purple-400 border border-purple-500/30">Chat Color</span>
              </div>
              <p className="text-gray-400 text-sm mb-6 max-w-[220px] leading-relaxed">
                Unlock /fly in the lobby, custom yellow chat color, and 5x monthly crate keys!
              </p>

              {/* Price Tag */}
              <div className="mb-4">
                <span className="text-gray-500 text-sm line-through mr-2">$19.99</span>
                <span className="text-3xl font-black text-white">$14.99</span>
              </div>

              <Link
                href="/shop"
                className="relative w-full overflow-hidden bg-gradient-to-r from-minecraft-diamond to-cyan-400 text-black font-bold uppercase tracking-wider px-6 py-3.5 rounded-xl hover:shadow-[0_0_30px_rgba(71,209,232,0.4)] transition-all duration-300 block group"
              >
                <span className="relative z-10 flex items-center justify-center gap-2">
                  <FaRocket className="group-hover:animate-bounce" />
                  View in Store
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-700" />
              </Link>
            </div>

            {/* Sale badge */}
            <motion.div
              initial={{ scale: 0, rotate: -12 }}
              whileInView={{ scale: 1, rotate: -12 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5, type: 'spring', stiffness: 300 }}
              className="absolute top-4 right-4 z-20"
            >
              <div className="bg-red-500 text-white text-[10px] font-black px-3 py-1 rounded-full shadow-lg shadow-red-500/30 uppercase tracking-wider">
                25% OFF
              </div>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
