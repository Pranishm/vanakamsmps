import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/auth_service.dart';

class ServerStatus {
  final bool online;
  final int playersOnline;
  final int playersMax;
  final String? motd;
  final String? version;
  final String? favicon;

  ServerStatus({
    required this.online,
    required this.playersOnline,
    required this.playersMax,
    this.motd,
    this.version,
    this.favicon,
  });

  factory ServerStatus.offline() => ServerStatus(
        online: false,
        playersOnline: 0,
        playersMax: 0,
      );

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    final players = json['players'] as Map<String, dynamic>? ?? {};
    return ServerStatus(
      online: json['online'] as bool? ?? false,
      playersOnline: players['online'] as int? ?? 0,
      playersMax: players['max'] as int? ?? 0,
      motd: json['motd'] as String?,
      version: json['version'] as String?,
      favicon: json['favicon'] as String?,
    );
  }
}

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ApiResponse({required this.success, this.message, this.data});
}

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final _client = http.Client();

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final session = AuthService().session;
    if (session != null) {
       // We pass these as custom headers. 
       // Note: The backend lib/session.ts needs to be updated to trust these for mobile.
       headers['X-User-Email'] = session.email;
       headers['X-User-Role'] = session.role;
       headers['X-User-Id'] = session.id;
    }
    return headers;
  }

  Future<ServerStatus> fetchServerStatus() async {
    try {
      final uri = Uri.parse(
        '${ServerConfig.apiBase}/api/server/status'
        '?host=${Uri.encodeComponent(ServerConfig.javaHost)}'
        '&port=${ServerConfig.javaPort}',
      );
      final res = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return ServerStatus.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return ServerStatus.offline();
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}/api/products');
      final res = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchNews() async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}/api/news');
      final res = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> fetchAdminDashboard() async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}/api/admin/dashboard');
      final res = await _client.get(uri, headers: _getHeaders()).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // --- GENERIC API MUTATIONS FOR BUTTON ACTIONS ---

  Future<ApiResponse> postData(String endpoint, Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}$endpoint');
      final res = await _client
          .post(uri, headers: _getHeaders(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(success: true, data: data);
      } else {
        return ApiResponse(
          success: false, 
          message: data is Map ? (data['error'] ?? data['message']) : 'Error ${res.statusCode}'
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection failed: $e');
    }
  }

  Stream<String> streamData(String endpoint, Map<String, dynamic> payload) async* {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}$endpoint');
      final request = http.Request('POST', uri);
      final headers = _getHeaders();
      request.headers.addAll(headers);
      request.headers['Content-Type'] = 'application/json'; // Explicitly set again to be sure
      request.body = jsonEncode(payload);

      final response = await _client.send(request);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        yield* response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());
      } else {
        final body = await response.stream.bytesToString();
        try {
          final data = jsonDecode(body);
          yield 'Error: ${data['error'] ?? data['message'] ?? response.statusCode}';
        } catch (_) {
          yield 'Error: $body';
        }
      }
    } catch (e) {
      yield 'Connection failed: $e';
    }
  }

  Future<ApiResponse> putData(String endpoint, Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}$endpoint');
      final res = await _client
          .put(uri, headers: _getHeaders(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(success: true, data: data);
      } else {
        return ApiResponse(
          success: false, 
          message: data is Map ? (data['error'] ?? data['message']) : 'Error ${res.statusCode}'
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection failed: $e');
    }
  }

  Future<ApiResponse> deleteData(String endpoint) async {
    try {
      final uri = Uri.parse('${ServerConfig.apiBase}$endpoint');
      final res = await _client.delete(uri, headers: _getHeaders()).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(success: true, data: data);
      } else {
        return ApiResponse(
          success: false, 
          message: data is Map ? (data['error'] ?? data['message']) : 'Error ${res.statusCode}'
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection failed: $e');
    }
  }
}
