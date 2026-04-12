import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vanakam_app/app_theme.dart';
import 'package:vanakam_app/screens/home_screen.dart';
import 'package:vanakam_app/screens/shop_screen.dart';
import 'package:vanakam_app/screens/vote_screen.dart';
import 'package:vanakam_app/screens/news_screen.dart';
import 'package:vanakam_app/widgets/glass_nav_bar.dart';
import 'package:vanakam_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF020617),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Load persisted session before rendering
  await AuthService().init();
  runApp(const VanakamApp());
}

class VanakamApp extends StatelessWidget {
  const VanakamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VANAKAMSMPs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.rajdhaniTextTheme(AppTheme.darkTheme.textTheme),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ShopScreen(),
    VoteScreen(),
    NewsScreen(),
  ];

  void _onNavTap(int index) {
    // Index 4 = Discord (open externally)
    if (index == 4) {
      _openDiscord();
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _openDiscord() async {
    final uri = Uri.parse('https://discord.gg/vanakamsmps');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020617),
              Color(0xFF111827),
              Color(0xFF020617),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // Floating glass nav bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
