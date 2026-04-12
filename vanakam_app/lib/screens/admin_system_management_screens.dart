import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';

// ----------------------------------------------------
// NEWSLETTER SCREEN
// ----------------------------------------------------
class AdminNewsletterScreen extends StatelessWidget {
  const AdminNewsletterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Newsletter Subscribers',
      icon: FontAwesomeIcons.envelope,
      items: [
        {'title': 'Campaign: Spring Promo', 'sub': 'Sent: 2026-04-01 • Opened: 42%', 'status': 'PROCESSED'},
        {'title': 'Campaign: Server Reset', 'sub': 'Scheduled for: 2026-04-15', 'status': 'PENDING'},
      ],
    );
  }
}

// ----------------------------------------------------
// SERVICES STATUS SCREEN
// ----------------------------------------------------
class AdminServicesStatusScreen extends StatelessWidget {
  const AdminServicesStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Services & Integrations',
      icon: FontAwesomeIcons.heartPulse,
      items: [
        {'title': 'Tebex Webstore', 'sub': 'Checks: OK • Latency: 120ms', 'status': 'ONLINE'},
        {'title': 'Discord Bot', 'sub': 'Checks: OK • Latency: 45ms', 'status': 'ONLINE'},
        {'title': 'Database Node 1', 'sub': 'Checks: OK • Latency: 12ms', 'status': 'ONLINE'},
      ],
    );
  }
}

// ----------------------------------------------------
// LOGS SCREEN
// ----------------------------------------------------
class AdminLogsScreen extends StatelessWidget {
  const AdminLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Audit Logs',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildLogItem('Update product price', 'Owner', '2026-04-12 10:15 / Target: Product'),
                _buildLogItem('Ban user', 'AdminBob', '2026-04-11 16:20 / Target: User'),
                _buildLogItem('Update permission node', 'Owner', '2026-04-10 12:00 / Target: Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String action, String user, String meta) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: McColors.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'By: $user • $meta',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// SETTINGS SCREEN
// ----------------------------------------------------
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'System Settings',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingsSection('General', [
            {'name': 'Site Name', 'val': 'VANAKAM SMPs'},
            {'name': 'Maintenance Mode', 'val': 'Disabled'},
          ]),
          const SizedBox(height: 20),
          _buildSettingsSection('Integrations', [
            {'name': 'Tebex Secret', 'val': '********************'},
            {'name': 'Discord Webhook', 'val': 'https://discord.com/api/webhooks/...'},
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Map<String, String>> kv) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: McColors.surfaceLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: kv.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e['name']!, style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(e['val']!, style: GoogleFonts.firaCode(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// PERMISSIONS SCREEN
// ----------------------------------------------------
class AdminPermissionsScreen extends StatelessWidget {
  const AdminPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildGenericListScreen(
      context: context,
      title: 'Admin Permissions',
      icon: FontAwesomeIcons.key,
      items: [
        {'title': 'Admin Role Access', 'sub': 'Users with this role can access the panel.', 'status': 'CONFIGURED'},
        {'title': 'Staff Panel Masking', 'sub': 'Limit staff view to only Tickets & Apps', 'status': 'CONFIGURED'},
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
                label: Text('Manage', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final res = await ApiService().postData('/api/admin/action', {'action': 'manage', 'module': title});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.success ? 'Management signal transmitted.' : 'Error: ${res.message}'), backgroundColor: res.success ? McColors.grass : Colors.redAccent),
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
                            color: item['status'] == 'ONLINE' || item['status'] == 'CONFIGURED' ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item['status'] == 'ONLINE' || item['status'] == 'CONFIGURED' ? Colors.greenAccent : Colors.white70,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16, color: Colors.white54),
                        onPressed: () async {
                          final res = await ApiService().postData('/api/admin/action', {'action': 'manage', 'module': title, 'id': item['title']});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.success ? 'Management signal transmitted.' : 'Error: ${res.message}'), backgroundColor: res.success ? McColors.grass : Colors.redAccent),
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
