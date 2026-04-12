import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanakam_app/constants.dart';

class CommunityDashboard extends StatefulWidget {
  const CommunityDashboard({super.key});

  @override
  State<CommunityDashboard> createState() => _CommunityDashboardState();
}

class _CommunityDashboardState extends State<CommunityDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: McColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: McColors.gold.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.star, size: 12, color: McColors.gold),
                const SizedBox(width: 8),
                Text(
                  'Community Hub',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: McColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Live Dashboard',
            style: GoogleFonts.rajdhani(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track leaderboards, patch notes, and featured ranks in real-time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
          ),
          const SizedBox(height: 24),

          // Leaderboard Card
          _buildLeaderboardCard(),
          const SizedBox(height: 16),

          // Patch Notes Card
          _buildPatchNotesCard(),
          const SizedBox(height: 16),

          // Featured Rank Card
          _buildFeaturedRankCard(),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    final players = [
      {'name': 'xPranish', 'score': '14,250', 'rank': 1},
      {'name': 'DragonSlayer', 'score': '12,890', 'rank': 2},
      {'name': 'BlockMaster', 'score': '11,340', 'rank': 3},
      {'name': 'CreeperKing', 'score': '9,780', 'rank': 4},
      {'name': 'DiamondMiner', 'score': '8,920', 'rank': 5},
    ];

    return Container(
      decoration: BoxDecoration(
        color: McColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: McColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [McColors.gold.withOpacity(0.3), McColors.gold.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: McColors.gold.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.trophy, color: McColors.gold, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Leaderboard', style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Top players this season', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Player list
          ...players.map((player) {
            final rank = player['rank'] as int;
            final medalColors = {
              1: McColors.gold,
              2: const Color(0xFFC0C0C0),
              3: const Color(0xFFCD7F32),
            };
            final medalColor = medalColors[rank];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: rank <= 3
                    ? (medalColor ?? Colors.white).withOpacity(0.05)
                    : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: rank == 1
                    ? Border.all(color: McColors.gold.withOpacity(0.15))
                    : null,
              ),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 28,
                    child: rank <= 3
                        ? Text(
                            rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                            style: const TextStyle(fontSize: 16),
                          )
                        : Text(
                            '#$rank',
                            style: GoogleFonts.firaCode(
                              fontSize: 13,
                              color: Colors.white38,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar placeholder
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (medalColor ?? McColors.diamond).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: (medalColor ?? Colors.white24).withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        (player['name'] as String)[0],
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: medalColor ?? Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player['name'] as String,
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: rank <= 3 ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  Text(
                    player['score'] as String,
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: medalColor ?? McColors.diamond,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPatchNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: McColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: McColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Decorative glow
          Positioned(
            top: -64,
            right: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: McColors.grass.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [McColors.grass.withOpacity(0.3), McColors.grass.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: McColors.grass.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.clockRotateLeft, color: McColors.grass, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patch Notes',
                            style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Latest updates', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text('All notes', style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.w600, color: McColors.grass)),
                        const SizedBox(width: 4),
                        const FaIcon(FontAwesomeIcons.arrowRight, size: 10, color: McColors.grass),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Latest patch
                _buildPatchEntry(
                  version: 'v2.1.0',
                  isNew: true,
                  title: 'The Economy Update',
                  description: 'Massive overhaul to the shop prices, new daily login rewards, and fixed the dupe glitch in Skyblock.',
                  tags: [
                    _buildTag('Economy', const Color(0xFF3B82F6)),
                    _buildTag('Bugfix', const Color(0xFFEF4444)),
                    _buildTag('Feature', const Color(0xFF22C55E)),
                  ],
                  lineColor: McColors.grass.withOpacity(0.3),
                  dotColor: McColors.grass,
                  dotGlow: true,
                ),
                const SizedBox(height: 20),

                // Previous patch
                _buildPatchEntry(
                  version: 'v2.0.5 • Last Week',
                  isNew: false,
                  title: 'Performance Patch',
                  description: 'Upgraded server RAM to 64GB DDR5 and optimized redstone tick calculations.',
                  tags: [],
                  lineColor: const Color(0xFF374151),
                  dotColor: const Color(0xFF4B5563),
                  dotGlow: false,
                  dimmed: true,
                ),
                const SizedBox(height: 20),

                // Older patch
                _buildPatchEntry(
                  version: 'v2.0.0 • 2 Weeks Ago',
                  isNew: false,
                  title: 'Season 2 Launch',
                  description: 'Fresh world reset, new spawn, and custom enchantments system.',
                  tags: [],
                  lineColor: const Color(0xFF1F2937),
                  dotColor: const Color(0xFF374151),
                  dotGlow: false,
                  dimmed: true,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatchEntry({
    required String version,
    required bool isNew,
    required String title,
    required String description,
    required List<Widget> tags,
    required Color lineColor,
    required Color dotColor,
    required bool dotGlow,
    bool dimmed = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: dotGlow
                        ? [BoxShadow(color: McColors.grass.withOpacity(0.5), blurRadius: 8)]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: lineColor),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      version,
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isNew ? McColors.grass : Colors.white38,
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: McColors.grass.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: McColors.grass.withOpacity(0.3)),
                        ),
                        child: Text(
                          'NEW',
                          style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.bold, color: McColors.grass),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: dimmed ? Colors.white54 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: dimmed ? Colors.white30 : Colors.white54,
                    height: 1.4,
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, children: tags),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFeaturedRankCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF030712)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: McColors.diamond.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Decorative glows
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: McColors.diamond.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
            ),
          ),
          // Sale badge
          Positioned(
            top: 16,
            right: 16,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 12),
                  ],
                ),
                child: Text(
                  '25% OFF',
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [McColors.diamond.withOpacity(0.3), McColors.diamond.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: McColors.diamond.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.gem, color: McColors.diamond, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Featured Rank', style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Limited time offer', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Crown emoji with float animation
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -8 * _floatController.value),
                      child: const Text('👑', style: TextStyle(fontSize: 56)),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Rank name
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFDE047), Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ).createShader(bounds),
                  child: Text(
                    'MVP+ RANK',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Perk badges
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPerkBadge('/fly', McColors.diamond),
                    _buildPerkBadge('5x Keys', McColors.gold),
                    _buildPerkBadge('Chat Color', const Color(0xFF8B5CF6)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlock /fly in the lobby, custom yellow chat color, and 5x monthly crate keys!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white54, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$19.99',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: Colors.white38,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$14.99',
                      style: GoogleFonts.rajdhani(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CTA button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [McColors.diamond, Color(0xFF22D3EE)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: McColors.diamond.withOpacity(0.3), blurRadius: 20),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.rocket, size: 14, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'VIEW IN STORE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
