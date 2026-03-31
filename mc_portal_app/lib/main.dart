import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Conditional imports
import 'widget_helper_stub.dart'
    if (dart.library.io) 'widget_helper_mobile.dart'
    if (dart.library.html) 'widget_helper_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetHelper.init();
  runApp(const McPortalApp());
}

class McPortalApp extends StatelessWidget {
  const McPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vanakam MC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F001A), // Even deeper obsidian
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF47D1E8), // Diamond
          secondary: Color(0xFF7BC043), // Grass
          tertiary: Color(0xFFF9E547), // Gold
          surface: Color(0xFF1A0033), // Obsidian
        ),
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 1; // Default to Dashboard for WOW factor
  String _serverStatus = 'Online'; // Default to show mock data first
  int _playersCount = 42;
  int _maxPlayers = 100;
  int _adminsCount = 3;
  bool _isRealData = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchAndSaveData();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchAndSaveData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchAndSaveData();
  }

  Future<void> _fetchAndSaveData() async {
    try {
      final response = await http.get(Uri.parse('https://vanakam.me/api/status')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _serverStatus = data['server'] == 'online' ? 'Online' : 'Offline';
          _playersCount = data['players'] ?? 0;
          _maxPlayers = data['max_players'] ?? 100;
          _adminsCount = data['admins_online'] ?? 0;
          _isRealData = true;
        });
        WidgetHelper.saveData(_serverStatus, _playersCount, _maxPlayers, _adminsCount);
      }
    } catch (e) {
      debugPrint('Fetch failed (Normal for Web/CORS): $e');
      // On Web, we'll keep the mock data if fetch fails due to CORS
      if (!kIsWeb) {
        setState(() { _serverStatus = 'Offline'; });
      } else {
         debugPrint('Using mock data for Web Preview...');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedIndexedStack(
        index: _currentIndex,
        children: [
          _buildWebTabPlaceholder(),
          _buildStatusDashboard(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0033).withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF47D1E8).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF47D1E8).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.language_rounded, 'Web'),
            _buildNavItem(1, Icons.dashboard_rounded, 'Portal'),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTabPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F001A), Color(0xFF1A0033)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF47D1E8).withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF47D1E8).withOpacity(0.1)),
                ),
                child: const Icon(Icons.security_rounded, color: Color(0xFF47D1E8), size: 64),
              ),
              const SizedBox(height: 32),
              const Text(
                'Portal Secure Browser',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'For security reasons, Vanakam.me is opened in a managed browser window.',
                style: TextStyle(fontSize: 16, color: Colors.white54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildModernButton(
                'Open Website',
                Icons.open_in_new_rounded,
                () => launchUrl(Uri.parse('https://vanakam.me'), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF47D1E8) : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF47D1E8) : Colors.white38,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF47D1E8).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF47D1E8),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatusDashboard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F001A), Color(0xFF1A0033), Color(0xFF0F001A)],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF47D1E8),
          onRefresh: _fetchAndSaveData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildMainStatusCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildGlassStatCard('Players', '$_playersCount/$_maxPlayers', Icons.people_rounded, const Color(0xFF47D1E8))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGlassStatCard('Staff', '$_adminsCount', Icons.shield_rounded, const Color(0xFFF9E547))),
                ],
              ),
              const SizedBox(height: 32),
              _buildWidgetInfoCard(),
              if (kIsWeb) ...[
                const SizedBox(height: 20),
                _buildWebWarning(),
              ],
              const SizedBox(height: 100), // Space for fab navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF47D1E8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF47D1E8).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, color: Color(0xFF47D1E8), size: 16),
              const SizedBox(width: 4),
              Text(
                'VANAKAM NETWORK'.toUpperCase(),
                style: const TextStyle(color: Color(0xFF47D1E8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
                const Text(
                  'Vanakam MC',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isRealData ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isRealData ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5)),
                  ),
                  child: Text(
                    _isRealData ? '● LIVE' : 'PREVIEW MODE',
                    style: TextStyle(
                      color: _isRealData ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            );
          }

  Widget _buildMainStatusCard() {
    bool isOnline = _serverStatus == 'Online';
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1587573089734-09cb69c0f2b4?q=80&w=2000&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? const Color(0xFF7BC043) : const Color(0xFFC62424)).withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              (isOnline ? const Color(0xFF7BC043) : const Color(0xFFC62424)).withOpacity(0.4),
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF7BC043) : const Color(0xFFC62424),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isOnline ? const Color(0xFF7BC043) : const Color(0xFFC62424)).withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _serverStatus.toUpperCase(),
                  style: TextStyle(
                    color: isOnline ? const Color(0xFF7BC043) : const Color(0xFFC62424),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Server Status',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const Text(
              'IP: vanakam.me',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildWidgetInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6F47), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.widgets_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Widgets',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  kIsWeb
                      ? 'Install the Android APK to enable home screen widgets.'
                      : 'Add a widget to your home screen to track player counts live!',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Web Preview: Live status and Website tab are limited by browser security (CORS/Iframe). Full features work in the native app!',
              style: TextStyle(color: Colors.amber, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const AnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _index) {
      _controller.reverse().then((_) {
        setState(() {
          _index = widget.index;
        });
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: IndexedStack(
        index: _index,
        children: widget.children,
      ),
    );
  }
}
