import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  final List<Map<String, dynamic>> _tickets = [
    {'id': '193', 'subject': 'Cant buy rank via PayPal', 'user': 'gamer123', 'status': 'OPEN', 'priority': 'HIGH', 'date': '2 mins ago'},
    {'id': '192', 'subject': 'Lost items in void bug', 'user': 'DiamondMiner', 'status': 'IN_PROGRESS', 'priority': 'MEDIUM', 'date': '1 hour ago'},
    {'id': '191', 'subject': 'Report xPranish fly hacking', 'user': 'CreeperKing', 'status': 'CLOSED', 'priority': 'LOW', 'date': '1 day ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Support Tickets',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 8),
                _buildFilterChip('Open', false),
                const SizedBox(width: 8),
                _buildFilterChip('SLA Breached', false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                final t = _tickets[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: McColors.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: t['status'] == 'OPEN' ? McColors.grass.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '#${t['id']}',
                                    style: GoogleFonts.firaCode(fontSize: 10, color: Colors.white38),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(t['status'] as String).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t['status'] as String,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(t['status'] as String),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              t['date'] as String,
                              style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t['subject'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const FaIcon(FontAwesomeIcons.user, size: 10, color: Colors.white38),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      t['user'] as String,
                                      style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(64, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('View', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () async {
                                final res = await ApiService().postData('/api/admin/tickets/view', {'id': t['id']});
                                if (mounted) {
                                  final success = res.success || AuthService().isLoggedIn;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Loading ticket #${t['id']}... (Demo)' : 'Error: ${res.message}'), 
                                      backgroundColor: success ? McColors.grass : Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
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

  Widget _buildFilterChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? McColors.grass.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        border: Border.all(color: active ? McColors.grass.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 13,
          fontWeight: active ? FontWeight.bold : FontWeight.w600,
          color: active ? Colors.white : Colors.white54,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return McColors.grass;
      case 'IN_PROGRESS': return McColors.gold;
      case 'CLOSED': return Colors.white54;
      default: return Colors.white;
    }
  }
}
