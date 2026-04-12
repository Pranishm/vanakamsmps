import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/widgets/server_status_widget.dart';
import 'package:vanakam_app/widgets/bedrock_card.dart';
import 'package:vanakam_app/widgets/community_dashboard.dart';
import 'package:vanakam_app/widgets/feature_card.dart';
import 'package:vanakam_app/widgets/game_mode_card.dart';
import 'package:vanakam_app/screens/admin_shell.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';
import 'package:vanakam_app/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _submittingApp = false;

  Future<void> _submitApplication() async {
    setState(() => _submittingApp = true);
    final response = await ApiService().postData('/api/staff-applications', {
      'age': 18,
      'timezone': 'UTC',
      'experience': 'Moderator on old server',
      'motivation': 'Want to help the community'
    });

    if (mounted) {
      setState(() => _submittingApp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success ? 'Application submitted successfully! Check your email.' : 'Error: ${response.message}',
            style: GoogleFonts.rajdhani(),
          ),
          backgroundColor: response.success ? McColors.grass : Colors.redAccent,
        ),
      );
    }
  }

  /// Chip shown when user is logged in — displays username + role badge + logout
  Widget _buildUserChip() {
    final auth = AuthService();
    final roleColor = auth.isOwner
        ? McColors.grass
        : auth.isAdmin
            ? McColors.diamond
            : Colors.white54;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF0F172A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: roleColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      auth.username.isNotEmpty ? auth.username[0].toUpperCase() : '?',
                      style: GoogleFonts.pressStart2p(fontSize: 24, color: roleColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(auth.username, style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(auth.email, style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white54)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(auth.role, style: GoogleFonts.rajdhani(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: roleColor)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 14),
                    label: Text('LOGOUT', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    onPressed: () async {
                      await AuthService().logout();
                      if (mounted) {
                        Navigator.pop(context); // Close sheet
                        setState(() {}); // Refresh UI
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: McColors.surfaceLight.withOpacity(0.8),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: roleColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  auth.username.isNotEmpty ? auth.username[0].toUpperCase() : '?',
                  style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.bold, color: roleColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              auth.username,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _copyIP(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: ServerConfig.javaDisplayAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'IP copied: ${ServerConfig.javaDisplayAddress}',
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
        ),
        backgroundColor: McColors.grass.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── HERO SECTION ──
        SliverToBoxAdapter(
          child: Stack(
            children: [
              // Background image with dark overlay
              Positioned.fill(
                child: Image.asset(
                  'assets/fondo.png',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.52),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              // Gradient overlay matching globals.css
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF2B9CF).withOpacity(0.08),
                        const Color(0xFF784874).withOpacity(0.12),
                        const Color(0xFF261626).withOpacity(0.22),
                        const Color(0xFF120A12).withOpacity(0.36),
                        const Color(0xFF0A060C).withOpacity(0.56),
                      ],
                      stops: const [0.0, 0.18, 0.48, 0.76, 1.0],
                    ),
                  ),
                ),
              ),
              // Bottom fade to scaffold bg
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        McColors.bgDarkStart,
                      ],
                    ),
                  ),
                ),
              ),
              // Hero content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Player badge & Admin
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ONLINE',
                                    style: GoogleFonts.rajdhani(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ADMIN button — only visible when user is admin/owner
                              if (AuthService().isAdmin)
                                FadeInDown(
                                  duration: const Duration(milliseconds: 800),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: McColors.surfaceLight.withOpacity(0.8),
                                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                    icon: const FaIcon(FontAwesomeIcons.shieldHalved, size: 11, color: Colors.white),
                                    label: Text(
                                      'ADMIN',
                                      style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell()));
                                    },
                                  ),
                                ),
                              if (AuthService().isAdmin) const SizedBox(width: 4),
                              // LOGIN / USER button
                              FadeInDown(
                                duration: const Duration(milliseconds: 900),
                                child: AuthService().isLoggedIn
                                    ? _buildUserChip()
                                    : ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: McColors.primary.withOpacity(0.8),
                                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: Size.zero,
                                        ),
                                        icon: const FaIcon(FontAwesomeIcons.rightToBracket, size: 11, color: Colors.white),
                                        label: Text('LOGIN', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                                        onPressed: () async {
                                          final result = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          );
                                          if (result == true && mounted) setState(() {});
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Main title with gradient
                      FadeInDown(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 200),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFDE7EE),
                              Color(0xFFF2B9CF),
                              Color(0xFFD58EAF),
                              Color(0xFFFFF2F6),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'VANAKAMSMPs',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      FadeInDown(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'The best Minecraft experience awaits. Join our community and live epic adventures.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Server Status Widget
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 600),
                        child: const ServerStatusWidget(),
                      ),
                      const SizedBox(height: 10),

                      // Bedrock Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 800),
                        child: const BedrockCard(),
                      ),
                      const SizedBox(height: 10),

                      // Staff Online + Discord row
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 1000),
                        child: Row(
                          children: [
                            Expanded(child: _buildStaffOnlineCard()),
                            const SizedBox(width: 10),
                            Expanded(child: _buildDiscordCard()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Scroll indicator
                      FadeIn(
                        delay: const Duration(seconds: 2),
                        child: Column(
                          children: [
                            Text(
                              'SCROLL',
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white38,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const FaIcon(FontAwesomeIcons.chevronDown, size: 12, color: Colors.white38),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── COMMUNITY DASHBOARD ──
        SliverToBoxAdapter(
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: const CommunityDashboard(),
          ),
        ),

        // ── FEATURES SECTION ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                FadeInUp(
                  child: Text(
                    'Why Choose Us?',
                    style: GoogleFonts.rajdhani(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Everything you need for the ultimate Minecraft experience.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 20),
                // Feature cards in a 2x2 grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                  children: const [
                    FeatureCard(
                      icon: FontAwesomeIcons.shieldHalved,
                      iconColor: McColors.grass,
                      title: 'Anti-Cheat',
                      description: 'Advanced protection system to keep the game fair for everyone.',
                    ),
                    FeatureCard(
                      icon: FontAwesomeIcons.fire,
                      iconColor: McColors.redstone,
                      title: 'Events',
                      description: 'Weekly tournaments and seasonal events with exclusive rewards.',
                    ),
                    FeatureCard(
                      icon: FontAwesomeIcons.users,
                      iconColor: McColors.diamond,
                      title: 'Community',
                      description: 'Active and friendly community with 24/7 staff support.',
                    ),
                    FeatureCard(
                      icon: FontAwesomeIcons.gem,
                      iconColor: McColors.gold,
                      title: 'Economy',
                      description: 'Player-driven economy with shops, auctions, and trading.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── GAME MODES SECTION ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                FadeInUp(
                  child: Text(
                    'Game Modes',
                    style: GoogleFonts.rajdhani(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Choose your adventure from multiple game modes.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: GameModeCard(
                    icon: FontAwesomeIcons.tree,
                    iconColor: McColors.grass,
                    name: 'Survival',
                    description: 'Classic survival with custom enchantments, land claims, and an active economy.',
                    onPlay: () {},
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: GameModeCard(
                    icon: FontAwesomeIcons.crosshairs,
                    iconColor: McColors.redstone,
                    name: 'PvP',
                    description: 'Competitive PvP arenas, ranked matches, and custom kits.',
                    onPlay: () {},
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GameModeCard(
                    icon: FontAwesomeIcons.cloudSun,
                    iconColor: McColors.diamond,
                    name: 'SkyBlock',
                    description: 'Build your island empire with custom challenges and minions.',
                    onPlay: () {},
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── GALLERY SECTION ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                FadeInUp(
                  child: Text(
                    'In-Game Server Gallery',
                    style: GoogleFonts.rajdhani(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Take a look at what awaits you inside the server.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 20),
                _buildGalleryItem('OneBlock', 'Start on a single block', 0),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildGalleryItem('SkyBlock', 'Your island awaits', 1)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildGalleryItem('PvP Events', 'Weekly tournaments', 2)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── STAFF APPLICATION SECTION ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: McColors.cardBg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: McColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Our Staff',
                      style: GoogleFonts.rajdhani(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Applications currently closed',
                      style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our staff applications will open again in May. Stay tuned to our Discord for future openings!',
                      style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white54, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Minecraft Username', enabled: false),
                    const SizedBox(height: 12),
                    _buildTextField('Discord Username', enabled: false),
                    const SizedBox(height: 12),
                    _buildTextField('Tell us about yourself', maxLines: 4, enabled: false),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Center(
                        child: Text(
                          'Submit Application',
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── FOOTER ──
        SliverToBoxAdapter(child: _buildFooter(context)),

        // Bottom padding for nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStaffOnlineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: McColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: McColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: McColors.grass.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.shieldHalved, size: 14, color: McColors.grass),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Staff Online',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '3 staff members',
            style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          // Stacked avatars
          SizedBox(
            height: 28,
            child: Stack(
              children: List.generate(3, (i) {
                return Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: [McColors.grass, McColors.diamond, McColors.gold][i].withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: McColors.bgDarkStart, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        ['S', 'M', 'A'][i],
                        style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white70),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscordCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: McColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5865F2).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5865F2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.discord, size: 14, color: Color(0xFF5865F2)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Discord',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Need help? Open a ticket',
            style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5865F2).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5865F2).withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                'Join Server',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5865F2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(String title, String subtitle, int delay) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 + delay * 100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: delay == 0 ? 200 : 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/fondo.png',
                fit: BoxFit.cover,
              ),
              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Text overlay
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(enabled ? 0.1 : 0.05)),
      ),
      child: TextField(
        enabled: enabled,
        maxLines: maxLines,
        style: GoogleFonts.rajdhani(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: McColors.diamond.withOpacity(0.15))),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF020714).withOpacity(0.72),
            const Color(0xFF020A1A).withOpacity(0.94),
          ],
        ),
      ),
      child: Column(
        children: [
          // Brand
          Text(
            'VANAKAMSMPs',
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Premium Minecraft server with custom game modes, active community, and 24/7 uptime.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38, height: 1.5),
          ),
          const SizedBox(height: 20),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(FontAwesomeIcons.discord, const Color(0xFF5865F2)),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.tiktok, Colors.white70),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.youtube, const Color(0xFFFF0000)),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.instagram, const Color(0xFFE1306C)),
            ],
          ),
          const SizedBox(height: 20),
          // Copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '© ${DateTime.now().year} VANAKAMSMPs. Made with ',
                style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38),
              ),
              const FaIcon(FontAwesomeIcons.heart, size: 12, color: Color(0xFFEF4444)),
              Text(
                ' for the community',
                style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Not affiliated with Mojang Studios.',
            style: GoogleFonts.rajdhani(fontSize: 11, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(FaIconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: FaIcon(icon, size: 18, color: color),
      ),
    );
  }
}
