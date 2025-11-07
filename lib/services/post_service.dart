import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';
const storage = FlutterSecureStorage();

class PostService {
  static String? _authToken;
  static bool _isGuest = false;

  // ✅ Initialize - call once in main.dart
  static Future<void> initialize() async {
    _authToken = await storage.read(key: 'auth_token');
    _isGuest = false; // ✅ ALWAYS false on app start
    print('✅ PostService initialized');
    print('   Token: ${_authToken != null ? "loaded" : "not found"}');
    print('   Guest: $_isGuest');
  }

  // ✅ Simple sync getters
  static String? get authToken => _authToken;
  static bool get isGuest => _isGuest;
  static bool get isLoggedIn => _authToken != null && !_isGuest;

  // ✅ Set guest mode (temporary)
  static void setGuestMode() {
    _isGuest = true;
    _authToken = null;
    print('👤 Guest mode activated (temporary)');
  }

  // ✅ Clear guest mode (sync, no async)
  static void clearGuestMode() {
    _isGuest = false;
    print('👤 Guest mode cleared');
  }

  // ✅ Save token persistently for authenticated users
  static Future<void> saveToken(String token) async {
    _authToken = token;
    _isGuest = false;
    await storage.write(key: 'auth_token', value: token);
    print('✅ Token saved (authenticated user)');
  }

  // ✅ Clear token on logout
  static Future<void> clearToken() async {
    _authToken = null;
    _isGuest = false;
    await storage.delete(key: 'auth_token');
    print('🗑️ Token cleared');
  }

  static void setAuthToken(String? token) {
    if (token != null) {
      saveToken(token);
    }
  }

  static void clearAuthToken() {
    _authToken = null;
    storage.delete(key: 'auth_token');
  }

  static String? getAuthToken() {
    return _authToken;
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String description,
    required String category,
    File? mediaFile,
  }) async {
    try {
      print('🚀 Creating post...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/api/posts/create'),
      );

      if (_authToken != null && _authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      request.headers['Accept'] = 'application/json';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (mediaFile != null) {
        int fileSize = await mediaFile.length();
        double fileSizeMB = fileSize / (1024 * 1024);
        if (fileSizeMB > 10) {
          return {'success': false, 'message': 'File too large (max 10MB)'};
        }
        String fileName = mediaFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath('media', mediaFile.path, filename: fileName),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Post created!',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> getAllPosts() async {
    try {
      final headers = {'Accept': 'application/json'};
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.get(
        Uri.parse('$apiUrl/api/posts'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> posts = [];

        if (data is List) {
          posts = data;
        } else if (data is Map) {
          posts = data['posts'] ?? data['data'] ?? [];
        }

        for (int i = 0; i < posts.length; i++) {
          if (posts[i] is Map) {
            Map<String, dynamic> post = Map<String, dynamic>.from(posts[i]);

            if (post['authorName'] == null || (post['authorName'] is String && post['authorName'].isEmpty)) {
              if (post['author'] is Map) {
                post['authorName'] = post['author']['name'] ??
                    post['author']['userName'] ??
                    post['author']['fullName'] ??
                    'Anonymous';
              } else if (post['author'] is String && post['author'].isNotEmpty) {
                post['authorName'] = post['author'];
              } else if (post['userName'] is String && post['userName'].isNotEmpty) {
                post['authorName'] = post['userName'];
              } else {
                post['authorName'] = 'Anonymous';
              }
            }

            posts[i] = post;
          }
        }

        return posts;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}
