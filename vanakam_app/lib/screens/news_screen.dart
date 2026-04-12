import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsItems = [
      {
        'title': 'The Economy Update v2.1.0',
        'date': 'April 10, 2026',
        'excerpt': 'Massive overhaul to the shop prices, new daily login rewards, and fixed the dupe glitch in Skyblock.',
        'tags': ['Economy', 'Bugfix', 'Feature'],
        'tagColors': [const Color(0xFF3B82F6), const Color(0xFFEF4444), McColors.grass],
      },
      {
        'title': 'Performance Patch v2.0.5',
        'date': 'April 5, 2026',
        'excerpt': 'Upgraded server RAM to 64GB DDR5 and optimized redstone tick calculations for smoother gameplay.',
        'tags': ['Performance'],
        'tagColors': [McColors.diamond],
      },
      {
        'title': 'Season 2 Launch v2.0.0',
        'date': 'March 28, 2026',
        'excerpt': 'Fresh world reset, brand new spawn area, and the custom enchantments system is here!',
        'tags': ['Season', 'Feature'],
        'tagColors': [McColors.gold, McColors.grass],
      },
      {
        'title': 'Community Event: Build Contest',
        'date': 'March 20, 2026',
        'excerpt': 'Participate in our weekly build contest! Theme: Medieval Castle. Winner gets MVP+ rank.',
        'tags': ['Event'],
        'tagColors': [const Color(0xFF8B5CF6)],
      },
      {
        'title': 'New Anti-Cheat System',
        'date': 'March 15, 2026',
        'excerpt': 'We\'ve deployed a next-gen anti-cheat to keep the game fair for everyone. Zero tolerance for hackers.',
        'tags': ['Security'],
        'tagColors': [McColors.redstone],
      },
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  FadeInDown(
                    child: Text(
                      'NEWS',
                      style: GoogleFonts.pressStart2p(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Stay updated with the latest announcements and patch notes.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final news = newsItems[index];
                final tags = news['tags'] as List<String>;
                final tagColors = news['tagColors'] as List<Color>;

                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: McColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: McColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          news['date'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: McColors.diamond,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          news['title'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Excerpt
                        Text(
                          news['excerpt'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            color: Colors.white54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Tags
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(tags.length, (i) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: tagColors[i].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: tagColors[i].withOpacity(0.2)),
                              ),
                              child: Text(
                                tags[i],
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tagColors[i],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: newsItems.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
