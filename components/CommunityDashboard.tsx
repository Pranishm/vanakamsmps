'use client';

import { motion } from 'framer-motion';
import { FaTrophy, FaHistory, FaGem, FaDiscord } from 'react-icons/fa';

export default function CommunityDashboard() {
  return (
    <section className="mx-auto max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Live Leaderboard */}
        <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}>
          <div className="bg-gray-900/50 backdrop-blur-sm border border-gray-800 rounded-2xl p-6 h-full flex flex-col">
            <div className="flex items-center gap-3 mb-6">
              <FaTrophy className="text-2xl text-minecraft-gold" />
              <h2 className="text-xl font-bold text-white">Live Leaderboard</h2>
            </div>
            <div className="flex-1 space-y-3">
              {[
                { name: 'Notch', kills: 1420, place: 1 },
                { name: 'Jeb_', kills: 890, place: 2 },
                { name: 'Dinnerbone', kills: 734, place: 3 },
                { name: 'Herobrine', kills: 666, place: 4 },
                { name: 'Steve', kills: 120, place: 5 },
              ].map((player, i) => (
                <div key={i} className="flex items-center justify-between p-3 bg-black/40 rounded-xl border border-white/5">
                  <div className="flex items-center gap-3">
                    <span className={`font-bold w-5 ${i === 0 ? 'text-yellow-400' : i === 1 ? 'text-gray-300' : i === 2 ? 'text-amber-600' : 'text-gray-600'}`}>#{player.place}</span>
                    <img src={`https://minotar.net/helm/${player.name}/32.png`} alt={player.name} className="w-8 h-8 rounded-md" />
                    <span className="text-white font-medium">{player.name}</span>
                  </div>
                  <div className="text-minecraft-redstone font-mono text-sm">{player.kills} Kills</div>
                </div>
              ))}
            </div>
          </div>
        </motion.div>

        {/* Changelog & Updates */}
        <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: 0.1 }}>
          <div className="bg-gray-900/50 backdrop-blur-sm border border-gray-800 rounded-2xl p-6 h-full flex flex-col">
            <div className="flex items-center gap-3 mb-6">
              <FaHistory className="text-2xl text-minecraft-grass" />
              <h2 className="text-xl font-bold text-white">Latest Patch Notes</h2>
            </div>
            <div className="flex-1 space-y-4">
              <div className="relative pl-6 border-l-2 border-minecraft-grass/30 pb-4">
                <div className="absolute w-3 h-3 bg-minecraft-grass rounded-full -left-[7px] top-1"></div>
                <div className="text-xs text-minecraft-grass font-bold mb-1">v2.1.0 • TODAY</div>
                <h3 className="text-white font-bold text-lg mb-2">The Economy Update</h3>
                <p className="text-gray-400 text-sm leading-relaxed">Massive overhaul to the shop prices, new daily login rewards, and fixed the dupe glitch in Skyblock.</p>
              </div>
              <div className="relative pl-6 border-l-2 border-gray-700 pb-4">
                <div className="absolute w-3 h-3 bg-gray-600 rounded-full -left-[7px] top-1"></div>
                <div className="text-xs text-gray-500 font-bold mb-1">v2.0.5 • LAST WEEK</div>
                <h3 className="text-gray-300 font-bold mb-2">Performance Patch</h3>
                <p className="text-gray-500 text-sm leading-relaxed">Upgraded server RAM to 64GB DDR5 and optimized redstone tick calculations.</p>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Ranks Showcase */}
        <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: 0.2 }}>
          <div className="bg-gradient-to-br from-gray-900 to-gray-950 border border-minecraft-diamond/30 rounded-2xl p-6 h-full flex flex-col relative overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-minecraft-diamond/10 rounded-full blur-3xl"></div>
            <div className="flex items-center gap-3 mb-6 relative z-10">
              <FaGem className="text-2xl text-minecraft-diamond" />
              <h2 className="text-xl font-bold text-white">Featured Rank</h2>
            </div>
            <div className="flex-1 flex flex-col justify-center items-center text-center relative z-10">
              <div className="text-5xl mb-4 animate-bounce">👑</div>
              <h3 className="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-300 to-amber-500 mb-2 font-[family-name:var(--font-press-start)] text-sm tracking-widest">MVP+ RANK</h3>
              <p className="text-gray-400 text-sm mb-6 max-w-[200px]">Unlock /fly in the lobby, custom yellow chat color, and 5x monthly crate keys!</p>
              <a href="/tienda" className="bg-minecraft-diamond text-black font-bold uppercase tracking-wider px-6 py-3 rounded-xl hover:bg-cyan-400 transition-colors shadow-[0_0_20px_rgba(71,209,232,0.3)] w-full block">
                Store Preview ($14.99)
              </a>
            </div>
          </div>
        </motion.div>
      </div>

    </section>
  );
}
