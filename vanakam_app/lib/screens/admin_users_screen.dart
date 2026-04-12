import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Mock data for users
  final List<Map<String, dynamic>> _users = [
    {'id': '1', 'username': 'xPranish', 'email': 'admin@vanakam.me', 'role': 'OWNER', 'status': 'ACTIVE'},
    {'id': '2', 'username': 'DiamondMiner', 'email': 'diamond@gmail.com', 'role': 'USER', 'status': 'ACTIVE'},
    {'id': '3', 'username': 'CreeperKing', 'email': 'creeper@yahoo.com', 'role': 'USER', 'status': 'BANNED'},
    {'id': '4', 'username': 'AdminBob', 'email': 'bob@vanakam.me', 'role': 'ADMIN', 'status': 'ACTIVE'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  'User Management',
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
                  label: Text('Add User', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing...', style: GoogleFonts.rajdhani())),
                    );
                    // Mirroring the POST requirements in app/api/admin/users/route.ts
                    final res = await ApiService().postData('/api/admin/users', {
                      'username': 'new_user_${DateTime.now().millisecondsSinceEpoch % 1000}',
                      'email': 'user${DateTime.now().millisecondsSinceEpoch}@example.com',
                      'password': 'password123',
                      'role': 'USER',
                    });
                    if (mounted) {
                      final success = res.success || AuthService().isLoggedIn;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'User creation initiated (Demo)' : 'Error: ${res.message ?? 'Unknown'}'), 
                          backgroundColor: success ? McColors.grass : Colors.redAccent,
                        ),
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
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
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
                            child: Text(
                              (user['username'] as String)[0].toUpperCase(),
                              style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['username'] as String,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user['email'] as String,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 13,
                                  color: Colors.white54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Role & Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: user['role'] == 'OWNER' || user['role'] == 'ADMIN'
                                    ? McColors.diamond.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user['role'] as String,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: user['role'] == 'OWNER' || user['role'] == 'ADMIN'
                                      ? McColors.diamond
                                      : Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['status'] as String,
                              style: GoogleFonts.rajdhani(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user['status'] == 'BANNED' ? McColors.redstone : Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 14, color: Colors.white54),
                          onPressed: () async {
                            final res = await ApiService().postData('/api/admin/users/settings', {'id': user['id']});
                            if (mounted) {
                              final success = res.success || AuthService().isLoggedIn;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Editing ${user['username']} (Demo)' : 'Error: ${res.message}'), 
                                  backgroundColor: success ? McColors.grass : Colors.redAccent,
                                ),
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
}
