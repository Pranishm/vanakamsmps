import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';

// ----------------------------------------------------
// BADGES SCREEN
// ----------------------------------------------------
class AdminBadgesScreen extends StatelessWidget {
  const AdminBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Badges',
      icon: FontAwesomeIcons.award,
      items: [
        {'title': 'VIP Founder', 'sub': 'Given to first 100 players', 'status': 'ACTIVE'},
        {'title': 'Bug Hunter', 'sub': 'Found a critical exploit', 'status': 'ACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// COUPONS SCREEN
// ----------------------------------------------------
class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Coupons',
      icon: FontAwesomeIcons.percent,
      items: [
        {'title': 'SUMMER_SALE', 'sub': '20% OFF - Expires in 5 days', 'status': 'ACTIVE'},
        {'title': 'WELCOME10', 'sub': '10% OFF - Infinite uses', 'status': 'ACTIVE'},
        {'title': 'BLACKFRIDAY', 'sub': '50% OFF - Expired', 'status': 'INACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// REFERRALS SCREEN
// ----------------------------------------------------
class AdminReferralsScreen extends StatelessWidget {
  const AdminReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Referrals',
      icon: FontAwesomeIcons.userGroup,
      items: [
        {'title': 'xPranish', 'sub': '14 Users Referred - \$10 Credit', 'status': 'ACTIVE'},
        {'title': 'DiamondMiner', 'sub': '2 Users Referred - \$0 Credit', 'status': 'ACTIVE'},
      ],
    );
  }
}

// ----------------------------------------------------
// LOYALTY SCREEN
// ----------------------------------------------------
class AdminLoyaltyScreen extends StatelessWidget {
  const AdminLoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Loyalty & Points',
      icon: FontAwesomeIcons.award,
      items: [
        {'title': 'xPranish', 'sub': 'Balance: 12,500 Points', 'status': 'ACTIVE'},
        {'title': 'CreeperKing', 'sub': 'Balance: 400 Points', 'status': 'ACTIVE'},
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
                            color: item['status'] == 'ACTIVE' ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item['status'] == 'ACTIVE' ? Colors.greenAccent : Colors.redAccent,
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
