import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';

// ----------------------------------------------------
// VOTEMAP SCREEN
// ----------------------------------------------------
class AdminVotemapScreen extends StatelessWidget {
  const AdminVotemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Map Voting Configuration',
      icon: FontAwesomeIcons.map,
      items: [
        {'title': 'Skywars - Frozen', 'sub': 'Next rotation: 2h 15m', 'status': 'ACTIVE'},
        {'title': 'Bedwars - Temple', 'sub': 'Next rotation: 1h 05m', 'status': 'ACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// FORUM SCREEN
// ----------------------------------------------------
class AdminForumScreen extends StatelessWidget {
  const AdminForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Community Forum',
      icon: FontAwesomeIcons.comments,
      items: [
        {'title': 'Server Rules Update', 'sub': 'Category: Announcements • Pinned', 'status': 'ACTIVE'},
        {'title': 'Bug Report: Skyblock', 'sub': 'Category: Support • 5 replies', 'status': 'ACTIVE'},
        {'title': 'Toxicity ban appeal', 'sub': 'Category: Appeals • Locked', 'status': 'INACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// BLOG/NEWS SCREEN
// ----------------------------------------------------
class AdminBlogScreen extends StatelessWidget {
  const AdminBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'News & Blog',
      icon: FontAwesomeIcons.newspaper,
      items: [
        {'title': 'Spring Update v1.2', 'sub': 'Author: Owner • Published: Today', 'status': 'ACTIVE'},
        {'title': 'Maintenance Schedule', 'sub': 'Author: Staff • Draft', 'status': 'INACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// PARTNER SCREEN
// ----------------------------------------------------
class AdminPartnerScreen extends StatelessWidget {
  const AdminPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Partners & Ads',
      icon: FontAwesomeIcons.shieldHalved,
      items: [
        {'title': 'TopG Server List', 'sub': 'Campaign: Monthly Promoted', 'status': 'ACTIVE'},
        {'title': 'Youtuber: MinecraftPro', 'sub': 'Campaign: Custom Code Promo', 'status': 'ACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// APPLICATIONS SCREEN
// ----------------------------------------------------
class AdminApplicationsScreen extends StatelessWidget {
  const AdminApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Staff Applications',
      icon: FontAwesomeIcons.clipboardList,
      items: [
        {'title': 'App #442 - Helper Role', 'sub': 'Applicant: xPlayer1x • Awaiting Review', 'status': 'ACTIVE'},
        {'title': 'App #441 - Builder Role', 'sub': 'Applicant: ArchCrafter • Interview Stage', 'status': 'ACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// GENERIC LIST RENDERER (Used for standard CRUD views)
// ----------------------------------------------------
Widget _buildGenericListScreen({required BuildContext context, required String title, required FaIconData icon, required List<Map<String, dynamic>> items}) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInDown(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: McColors.grass.withOpacity(0.2),
                  foregroundColor: McColors.grass,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                label: Text('Create New', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final res = await ApiService().postData('/api/admin/action', {'action': 'create', 'module': title});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.success ? 'Action processed successfully!' : 'Error: ${res.message}'), backgroundColor: res.success ? McColors.grass : Colors.redAccent),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: McColors.surfaceLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(icon, size: 16, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              item['sub'] as String,
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item['status'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item['status'] == 'ACTIVE' ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item['status'] == 'ACTIVE' ? Colors.greenAccent : Colors.white70,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16, color: Colors.white54),
                        onPressed: () async {
                          final res = await ApiService().postData('/api/admin/action', {'action': 'edit', 'module': title, 'id': item['title']});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.success ? 'Opening editor...' : 'Error: ${res.message}'), backgroundColor: res.success ? McColors.grass : Colors.redAccent),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
