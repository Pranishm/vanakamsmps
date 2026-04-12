import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vanakam_app/constants.dart';

class VoteScreen extends StatelessWidget {
  const VoteScreen({super.key});

  Future<void> _openVoteLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'VOTE',
                      style: GoogleFonts.pressStart2p(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Vote daily to support the server and earn rewards!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rewards info card
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [McColors.grass.withOpacity(0.12), McColors.diamond.withOpacity(0.08)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: McColors.grass.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const FaIcon(FontAwesomeIcons.gift, size: 40, color: McColors.grass),
                          const SizedBox(height: 12),
                          Text(
                            'Vote Rewards',
                            style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          _buildRewardItem('1 Vote Key per vote'),
                          _buildRewardItem('Bonus coins every 5 votes'),
                          _buildRewardItem('Monthly top voter prizes'),
                          _buildRewardItem('Exclusive voter-only cosmetics'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vote sites
                  ...List.generate(3, (index) {
                    final sites = [
                      {'name': 'TopMinecraftServers', 'url': 'https://topminecraftservers.org'},
                      {'name': 'MinecraftServers.org', 'url': 'https://minecraftservers.org'},
                      {'name': 'Planet Minecraft', 'url': 'https://planetminecraft.com'},
                    ];
                    return FadeInUp(
                      delay: Duration(milliseconds: 300 + index * 100),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVoteSite(sites[index]),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildRewardItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.check, size: 12, color: McColors.grass),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteSite(Map<String, String> site) {
    return GestureDetector(
      onTap: () => _openVoteLink(site['url']!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: McColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: McColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: McColors.diamond.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.thumbsUp, size: 18, color: McColors.diamond),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site['name']!,
                    style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Click to vote',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: McColors.grass.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: McColors.grass.withOpacity(0.2)),
              ),
              child: Text(
                'VOTE',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: McColors.grass,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
