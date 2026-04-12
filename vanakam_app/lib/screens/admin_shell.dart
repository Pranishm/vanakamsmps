import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/screens/admin_dashboard_screen.dart';
import 'package:vanakam_app/screens/admin_placeholder_screen.dart';
import 'package:vanakam_app/screens/admin_users_screen.dart';
import 'package:vanakam_app/screens/admin_products_screen.dart';
import 'package:vanakam_app/screens/admin_tickets_screen.dart';
import 'package:vanakam_app/screens/admin_server_screen.dart';
import 'package:vanakam_app/screens/admin_store_management_screens.dart';
import 'package:vanakam_app/screens/admin_content_management_screens.dart';
import 'package:vanakam_app/screens/admin_system_management_screens.dart';
import 'package:vanakam_app/services/auth_service.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  String _currentRoute = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _menuItems = [
    {'key': 'dashboard', 'name': 'Dashboard', 'icon': FontAwesomeIcons.house, 'group': 'main'},
    {'key': 'users', 'name': 'Users', 'icon': FontAwesomeIcons.users, 'group': 'main'},
    {'key': 'badges', 'name': 'Badges', 'icon': FontAwesomeIcons.award, 'group': 'main'},
    {'key': 'products', 'name': 'Store Catalog', 'icon': FontAwesomeIcons.cartShopping, 'group': 'main'},
    {'key': 'coupons', 'name': 'Coupons', 'icon': FontAwesomeIcons.percent, 'group': 'main'},
    {'key': 'referrals', 'name': 'Referrals', 'icon': FontAwesomeIcons.userGroup, 'group': 'main'},
    {'key': 'loyalty', 'name': 'Loyalty', 'icon': FontAwesomeIcons.award, 'group': 'main'},
    {'key': 'votemap', 'name': 'Map Voting', 'icon': FontAwesomeIcons.map, 'group': 'main'},
    {'key': 'tickets', 'name': 'Tickets', 'icon': FontAwesomeIcons.ticket, 'group': 'main'},
    {'key': 'applications', 'name': 'Staff Apps', 'icon': FontAwesomeIcons.clipboardList, 'group': 'main'},
    
    {'key': 'forum', 'name': 'Forum', 'icon': FontAwesomeIcons.comments, 'group': 'content'},
    {'key': 'blog', 'name': 'News & Blog', 'icon': FontAwesomeIcons.newspaper, 'group': 'content'},
    {'key': 'partner', 'name': 'Partners', 'icon': FontAwesomeIcons.shieldHalved, 'group': 'content'},
    
    {'key': 'newsletter', 'name': 'Newsletter', 'icon': FontAwesomeIcons.envelope, 'group': 'system'},
    {'key': 'services-status', 'name': 'Services Status', 'icon': FontAwesomeIcons.heartPulse, 'group': 'system'},
    {'key': 'server', 'name': 'Server Control', 'icon': FontAwesomeIcons.server, 'group': 'system'},
    {'key': 'logs', 'name': 'Audit Logs', 'icon': FontAwesomeIcons.clockRotateLeft, 'group': 'system'},
    {'key': 'settings', 'name': 'System Settings', 'icon': FontAwesomeIcons.gear, 'group': 'system'},
    {'key': 'permissions', 'name': 'Permissions', 'icon': FontAwesomeIcons.key, 'group': 'system'},
  ];

  void _onNavigate(String key) {
    setState(() => _currentRoute = key);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // Close drawer
    }
  }

  Widget _buildScreen() {
    switch (_currentRoute) {
      case 'dashboard': return const AdminDashboardScreen();
      case 'users': return const AdminUsersScreen();
      case 'products': return const AdminProductsScreen();
      case 'tickets': return const AdminTicketsScreen();
      case 'server': return const AdminServerScreen();
      // Store Management
      case 'badges': return const AdminBadgesScreen();
      case 'coupons': return const AdminCouponsScreen();
      case 'referrals': return const AdminReferralsScreen();
      case 'loyalty': return const AdminLoyaltyScreen();
      // Content Management
      case 'votemap': return const AdminVotemapScreen();
      case 'forum': return const AdminForumScreen();
      case 'blog': return const AdminBlogScreen();
      case 'partner': return const AdminPartnerScreen();
      case 'applications': return const AdminApplicationsScreen();
      // System Management
      case 'newsletter': return const AdminNewsletterScreen();
      case 'services-status': return const AdminServicesStatusScreen();
      case 'logs': return const AdminLogsScreen();
      case 'settings': return const AdminSettingsScreen();
      case 'permissions': return const AdminPermissionsScreen();
      
      default:
        return AdminPlaceholderScreen(
          title: _menuItems.firstWhere((m) => m['key'] == _currentRoute)['name'] as String,
          icon: _menuItems.firstWhere((m) => m['key'] == _currentRoute)['icon'] as FaIconData,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _menuItems.firstWhere((m) => m['key'] == _currentRoute);
    final title = currentItem['name'] as String;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF020617),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars, color: Colors.white, size: 20),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN PANEL',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white54,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context), // Go back to app
            tooltip: 'Exit Admin',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ],
                ),
              ),
            ),
          ),
          // Content
          _buildScreen(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF08101D),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.shieldHalved, color: Color(0xFFA5F3FC), size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ADMIN PANEL',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        'Control Center',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildNavSection('Operational Overview', 'main'),
                _buildNavSection('Content Management', 'content'),
                _buildNavSection('System & Settings', 'system'),
              ],
            ),
          ),

          // Footer — real session data from AuthService
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Signed in as', style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white54)),
                          Text(
                            AuthService().email,
                            style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleBadgeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AuthService().role,
                        style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.bold, color: _getRoleBadgeColor()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.house, size: 14, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Return to Website',
                          style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildNavSection(String title, String group) {
    final auth = AuthService();
    // Filter items by role-based visibility (mirrors canSee() from admin/layout.tsx)
    final items = _menuItems
        .where((m) => m['group'] == group)
        .where((m) => auth.session?.canSee(m['key'] as String) ?? true)
        .toList();

    // Permissions section is OWNER-only (separate section in Node.js)
    if (group == 'system' && !auth.isOwner) {
      items.removeWhere((m) => m['key'] == 'permissions');
    }

    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white54,
            ),
          ),
        ),
        ...items.map((item) {
          final isActive = _currentRoute == item['key'];
          return InkWell(
            onTap: () => _onNavigate(item['key'] as String),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  FaIcon(
                    item['icon'] as FaIconData,
                    size: 16,
                    color: isActive ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['name'] as String,
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        color: isActive ? Colors.white : Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getRoleBadgeColor() {
    final role = AuthService().role;
    switch (role) {
      case 'OWNER':
        return McColors.grass;
      case 'ADMIN':
        return McColors.diamond;
      case 'STAFF':
        return McColors.gold;
      default:
        return Colors.white54;
    }
  }
}

