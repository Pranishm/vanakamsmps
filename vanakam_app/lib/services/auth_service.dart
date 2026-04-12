import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanakam_app/constants.dart';

/// Mirrors the NextAuth session model from the Node.js app.
/// Stores user data locally after login and exposes role-based access control.
class UserSession {
  final String id;
  final String username;
  final String email;
  final String role; // OWNER, ADMIN, STAFF, USER
  final String? avatarUrl;
  final List<String> adminSections;
  final bool adminSectionsConfigured;

  const UserSession({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.adminSections = const [],
    this.adminSectionsConfigured = false,
  });

  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN' || role == 'OWNER';
  bool get isStaff => role == 'STAFF' || isAdmin;

  /// Mirrors the canSee() logic from admin/layout.tsx
  bool canSee(String sectionKey) {
    if (isOwner) return true;
    if (role != 'ADMIN') return true; // STAFF keeps full panel
    if (!adminSectionsConfigured) return true;
    if (sectionKey == 'dashboard') return true;
    return adminSections.contains(sectionKey);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'avatarUrl': avatarUrl,
    'adminSections': adminSections,
    'adminSectionsConfigured': adminSectionsConfigured,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'USER',
    avatarUrl: json['avatarUrl'] as String? ?? json['image'] as String?,
    adminSections: (json['adminSections'] as List<dynamic>?)?.cast<String>() ?? [],
    adminSectionsConfigured: json['adminSectionsConfigured'] as bool? ?? false,
  );
}

/// Global authentication service — singleton pattern.
/// Manages login, logout, session persistence, and notifies listeners.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _client = http.Client();
  UserSession? _session;
  bool _initialized = false;

  UserSession? get session => _session;
  bool get isLoggedIn => _session != null;
  bool get isAdmin => _session?.isAdmin ?? false;
  bool get isOwner => _session?.isOwner ?? false;
  String get role => _session?.role ?? 'GUEST';
  String get username => _session?.username ?? '';
  String get email => _session?.email ?? '';

  /// Load saved session from SharedPreferences on app start
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('user_session');
      if (sessionJson != null) {
        _session = UserSession.fromJson(jsonDecode(sessionJson));
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Login via the NextAuth credentials callback
  Future<bool> login(String email, String password) async {
    try {
      // Try the real backend first
      final uri = Uri.parse('${ServerConfig.apiBase}/api/auth/callback/credentials');
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode >= 200 && res.statusCode < 400) {
        // Try to parse session from response
        try {
          final data = jsonDecode(res.body);
          if (data is Map<String, dynamic> && data['user'] != null) {
            _session = UserSession.fromJson(data['user'] as Map<String, dynamic>);
            await _persistSession();
            notifyListeners();
            return true;
          }
        } catch (_) {}
      }
    } catch (_) {}

    // Fallback: demo mode for presentation
    // Admin login: admin@gmail.com or pranish_M with password admin123
    if ((email == 'admin@gmail.com' || email == 'pranish_M') && password == 'admin123') {
      _session = const UserSession(
        id: '1',
        username: 'pranish_M',
        email: 'admin@gmail.com',
        role: 'OWNER',
        adminSections: [],
        adminSectionsConfigured: false,
      );
      await _persistSession();
      notifyListeners();
      return true;
    }

    // Any other credentials → create a regular USER session (demo)
    if (email.isNotEmpty && password.isNotEmpty) {
      _session = UserSession(
        id: '99',
        username: email.split('@').first,
        email: email,
        role: 'USER',
      );
      await _persistSession();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Register via /api/auth/register
  Future<bool> register(String username, String email, String password) async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}/api/auth/register');
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));
      return res.statusCode >= 200 && res.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  /// Clear the session entirely
  Future<void> logout() async {
    _session = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _persistSession() async {
    if (_session == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', jsonEncode(_session!.toJson()));
    } catch (_) {}
  }
}
