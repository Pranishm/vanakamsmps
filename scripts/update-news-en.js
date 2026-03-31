const mongoose = require('mongoose');
require('dotenv').config();

const BlogPostSchema = new mongoose.Schema({
  title: String,
  slug: { type: String, unique: true },
  content: String,
  excerpt: String,
  author: String,
  authorId: String,
  coverImage: String,
  tags: [String],
  isPublished: Boolean,
  publishedAt: Date,
  views: Number,
  createdAt: { type: Date, default: Date.now },
});

async function main() {
  await mongoose.connect(process.env.MONGODB_URI);
  const BlogPost = mongoose.models.BlogPost || mongoose.model('BlogPost', BlogPostSchema);
  
  await BlogPost.deleteMany({}); // Delete all existing Spanish news
  
  const posts = [
    {
      title: 'Welcome to VANAKAMSMPs!',
      slug: 'welcome-to-vanakamsmps',
      content: `# Welcome to VANAKAMSMPs! 🎮\n\nWe are excited to welcome you to our incredible Minecraft server. After months of development and exhaustive testing, we finally open our doors to the whole community.\n\n## What makes us special?\n\n### 🌟 Active Community\nWe have a vibrant and friendly community of players from all over the world. Our Discord is always active with events, giveaways, and lots of fun.\n\n### 🛡️ Dedicated 24/7 Staff\nOur team of moderators and administrators is available 24 hours a day to ensure your experience is the best possible.\n\n### 🎪 Weekly Events\nEvery week we organize epic events with incredible prizes:\n- **Mondays**: Build Battles\n- **Wednesdays**: PvP Tournaments\n- **Fridays**: Parkour Races\n- **Saturdays**: Drop Parties\n- **Sundays**: Boss Raids\n\n### ⚡ Anti-Lag System\nWe have invested in the best infrastructure to offer you a smooth and uninterrupted gaming experience.\n\n### 🔒 Advanced Protection\nLatest generation anti-griefing system that protects all your builds and items.\n\n## Available Game Modes\n\n- **Survival**: Enhanced vanilla experience with economy and jobs\n- **Skyblock**: Start from scratch on your floating island\n- **Creative**: Build whatever you imagine without limits\n- **PvP**: Show your combat skills\n- **MiniGames**: Bedwars, Skywars, Duels and more\n\n## Join Now\n\nConnect to: **marketing-great.gl.joinmc.link**\n\nWe are waiting for you! 🎉`,
      excerpt: 'We officially welcome you to VANAKAMSMPs. Discover everything we have prepared for you in this new adventure.',
      author: 'Admin',
      authorId: 'admin_id_placeholder', 
      coverImage: '/images/welcome-banner.png',
      tags: ['Announcement', 'Welcome', 'Info'],
      isPublished: true,
      publishedAt: new Date(),
      views: 245,
    },
    {
      title: 'Update 1.5: New Skyblock Season',
      slug: 'update-1-5-new-skyblock-season',
      content: `# Update 1.5: New Skyblock Season 🌴\n\nThe most anticipated season is finally here! We've completely redesigned the Skyblock experience with tons of new content.\n\n## Main New Features\n\n### 🏝️ New Island System\n- Larger islands from the start\n- New exclusive biomes\n- Improved expansion system\n- Increased member limit\n\n### 💎 Custom Minions\nUnlock up to 15 different types of minions that will help you farm resources automatically:\n- Cobblestone Minion\n- Wheat Minion\n- Cow Minion\n- Iron Minion\n- And many more!\n\n### 🏪 Improved Island Shop\nNew interface with organized categories and balanced prices. Now it's easier than ever to find what you need.\n\n### 🎯 Quest System\nComplete daily and weekly quests to get exclusive rewards:\n- Bonus coins\n- Rare items\n- Multiplied experience\n- Crate keys\n\n### 🏆 Top Islands\nCompete for the top 3 best islands and win incredible prizes:\n- **1st Place**: Permanent VIP+ Rank + 10,000 coins\n- **2nd Place**: 5 Epic Keys + 5,000 coins\n- **3rd Place**: 3 Epic Keys + 2,500 coins\n\n## Bug Fixes\n\n- Fixed lag in cobblestone generators\n- Fixed error with hoppers\n- Improved general performance\n- Fixed duplication glitch\n\n## Season Reset\n\n⚠️ **IMPORTANT**: This update includes a complete reset. All players will start from scratch with the following compensations:\n\n- **VIP**: 2,000 starting coins\n- **VIP+**: 5,000 coins + Starter Kit\n- **MVP**: 10,000 coins + Elite Kit\n\nSee you in the new season! 🚀`,
      excerpt: 'Discover all the new features of the new Skyblock season with minions, quests and much more.',
      author: 'Admin',
      authorId: 'admin_id_placeholder',
      coverImage: '/images/skyblock-update.png',
      tags: ['Update', 'Skyblock', 'Season'],
      isPublished: true,
      publishedAt: new Date(Date.now() - 86400000 * 2),
      views: 432,
    },
    {
      title: '🎉 Weekly Giveaway: MVP Rank + 10 Epic Keys',
      slug: 'weekly-giveaway-mvp-rank',
      content: `# 🎉 Weekly Giveaway: Participate and Win!\n\nThis week we have an EPIC giveaway for our incredible community.\n\n## Prizes\n\n### 🏆 Grand Prize\n- **1 MVP Rank** (Valued at $34.99)\n- **10 Epic Keys**\n- **20,000 Server Coins**\n\n### 🥈 Second Prize\n- **VIP+ Rank** (Valued at $19.99)\n- **5 Epic Keys**\n- **10,000 Coins**\n\n### 🥉 Third Prize\n- **VIP Rank** (Valued at $9.99)\n- **3 Epic Keys**\n- **5,000 Coins**\n\n## How to Participate\n\nIt's very easy to enter the giveaway:\n\n1. ✅ Join our Discord server\n2. ✅ React to the giveaway message with 🎉\n3. ✅ Share the giveaway on your status/story\n4. ✅ (Optional) Invite friends for extra tickets\n\n## Rules\n\n- You must be a member of the Minecraft server\n- One entry per person\n- Alt/fake accounts are not allowed\n- The giveaway will take place on **Sunday at 8PM**\n- Winners will be contacted via Discord\n\n## Extra Tickets\n\nIncrease your chances of winning!\n\n- +1 Ticket: For each friend you invite (max. 5)\n- +2 Tickets: If you have VIP rank or higher\n- +3 Tickets: If you are an active streamer/youtuber\n\n## Previous Winners\n\nLast week the lucky ones were:\n- **xX_Pro_Xx**: VIP+ Rank\n- **Minecraftero123**: Elite Pack\n- **BuilderPro**: 10,000 Coins\n\nGood luck to everyone! 🍀\n\n**Discord**: discord.gg/HN2hprkrKB`,
      excerpt: 'Participate in our weekly giveaway and win amazing prizes including ranks, epic keys and coins.',
      author: 'Admin',
      authorId: 'admin_id_placeholder',
      coverImage: '/images/giveaway.png',
      tags: ['Giveaway', 'Event', 'Prizes'],
      isPublished: true,
      publishedAt: new Date(Date.now() - 86400000 * 4), 
      views: 589,
    }
  ];

  await BlogPost.insertMany(posts);
  console.log('✅ English posts successfully created.');
  process.exit(0);
}

main().catch(console.error);
