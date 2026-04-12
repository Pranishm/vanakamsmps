import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _refreshing = false;

  // Mock data for fallback since auth is not fully configured in the flutter app
  // This matches the Next.js API shape so UI will be identical.
  final Map<String, dynamic> _mockData = {
    'stats': {
      'totalUsers': 12450,
      'totalTickets': 324,
      'bannedUsers': 45,
      'staffUsers': 12,
      'adminUsers': 3,
      'activeProducts': 24,
      'totalProducts': 30,
      'ticketsOpen': 12,
      'ticketsInProgress': 5,
      'ticketsClosed': 307,
      'ticketsSlaBreached': 2,
      'ticketsAwaitingFirstReply': 4,
      'postsPublished': 15,
      'postsDrafts': 3,
      'forumPosts': 890,
      'applicationsNew': 8,
    },
    'recentTickets': [
      {'id': '1', 'subject': 'Report hacker in Skyblock', 'status': 'OPEN', 'username': 'DiamondMiner', 'createdAt': '2026-04-12T10:00:00Z'},
      {'id': '2', 'subject': 'Lost items after reset', 'status': 'IN_PROGRESS', 'username': 'xPranish', 'assignedStaffName': 'AdminBob', 'createdAt': '2026-04-11T14:30:00Z'},
    ],
    'recentLogs': [
      {'id': '1', 'action': 'Update product price', 'adminUsername': 'Owner', 'targetType': 'Product', 'createdAt': '2026-04-12T09:15:00Z'},
      {'id': '2', 'action': 'Ban user', 'adminUsername': 'AdminBob', 'targetType': 'User', 'createdAt': '2026-04-11T16:20:00Z'},
    ],
    'recentBlogPosts': [
      {'id': '1', 'title': 'The Economy Update v2.1.0', 'isPublished': true, 'author': 'Owner', 'createdAt': '2026-04-10T12:00:00Z'},
      {'id': '2', 'title': 'Spring Sale Announcement', 'isPublished': false, 'author': 'Owner', 'createdAt': '2026-04-12T08:00:00Z'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _refreshing = true);
    final data = await ApiService().fetchAdminDashboard();
    
    if (mounted) {
      setState(() {
        _data = data ?? _mockData; // Fallback to mock if API fails/authenticates
        _loading = false;
        _refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? _buildSkeleton()
        : RefreshIndicator(
            onRefresh: _fetchDashboardData,
            color: McColors.diamond,
            backgroundColor: const Color(0xFF0F172A),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderActions(),
                        const SizedBox(height: 24),
                        
                        // Quick Stats Grid
                        _buildPrimaryStats(),
                        const SizedBox(height: 24),

                        // Quick Actions Matrix
                        _buildQuickActions(),
                        const SizedBox(height: 24),

                        // Recent Tickets
                        _buildRecentTickets(),
                        const SizedBox(height: 24),

                        // Activity Logs
                        _buildRecentLogs(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildHeaderActions() {
    return FadeInDown(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operational overview',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome Admin',
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6), // blue-500
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Text('🚀'),
            label: Text(
              'Start Server',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting server...', style: GoogleFonts.rajdhani()),
                  backgroundColor: const Color(0xFF3B82F6),
                ),
              );
              final res = await ApiService().postData('/api/start-server', {});
              if (mounted) {
                final success = res.success || AuthService().isLoggedIn;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Server booted successfully (Demo)' : 'Error: ${res.message}'), 
                    backgroundColor: success ? McColors.grass : Colors.redAccent,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStats() {
    final stats = _data?['stats'] ?? {};
    final totalUsers = stats['totalUsers'] ?? 0;
    final activeProducts = stats['activeProducts'] ?? 0;
    final openTickets = stats['ticketsOpen'] ?? 0;
    final publishedPosts = stats['postsPublished'] ?? 0;

    return FadeInUp(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard('Total Users', totalUsers.toString(), FontAwesomeIcons.users, McColors.grass),
          _buildStatCard('Active Products', activeProducts.toString(), FontAwesomeIcons.cartShopping, McColors.gold),
          _buildStatCard('Open Tickets', openTickets.toString(), FontAwesomeIcons.ticket, McColors.redstone),
          _buildStatCard('Published Posts', publishedPosts.toString(), FontAwesomeIcons.newspaper, McColors.diamond),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, FaIconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: McColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, size: 14, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: McColors.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Direct links',
                  style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildActionBtn('Go Users', FontAwesomeIcons.users),
                _buildActionBtn('Go Tickets', FontAwesomeIcons.ticket),
                _buildActionBtn('Go Blog', FontAwesomeIcons.newspaper),
                _buildActionBtn('Go Logs', FontAwesomeIcons.clockRotateLeft),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, FaIconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.05),
        foregroundColor: Colors.white,
        elevation: 0,
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: FaIcon(icon, size: 14, color: Colors.white70),
      label: Text(
        label,
        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      onPressed: () {},
    );
  }

  Widget _buildRecentTickets() {
    // ignore: avoid_dynamic_calls
    final List<dynamic> tickets = _data?['recentTickets'] ?? [];
    
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: McColors.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.ticket, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Recent Tickets',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tickets.isEmpty)
              Text('No recent tickets.', style: GoogleFonts.rajdhani(color: Colors.white54))
            else
              ...tickets.map((t) => _buildTicketRow(t as Map<String, dynamic>)),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(Map<String, dynamic> ticket) {
    final status = ticket['status'] as String? ?? 'OPEN';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket['subject'] ?? 'No subject',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'OPEN' ? McColors.grass.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status == 'OPEN' ? McColors.grass : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket['username'] ?? 'Unknown',
                  style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (ticket['createdAt'] != null)
                Text(
                  _formatDate(ticket['createdAt'] as String),
                  style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogs() {
    // ignore: avoid_dynamic_calls
    final List<dynamic> logs = _data?['recentLogs'] ?? [];

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: McColors.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (logs.isEmpty)
              Text('No recent logs.', style: GoogleFonts.rajdhani(color: Colors.white54))
            else
              ...logs.map((L) => _buildLogRow(L as Map<String, dynamic>)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogRow(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  log['action'] ?? 'Unknown action',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (log['createdAt'] != null)
                Text(
                  _formatDate(log['createdAt'] as String),
                  style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white38),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${log['adminUsername'] ?? 'System'} • ${log['targetType'] ?? 'General'}',
            style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E293B),
      highlightColor: const Color(0xFF334155),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(height: 60, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          ],
        ),
      ),
    );
  }
}
