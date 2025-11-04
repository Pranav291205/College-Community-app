import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';
  static String? authToken;

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String branch,
    required String year,
    List<String>? interests,
  }) async {
    try {
      print('📝 Registering user...');

      Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'branch': branch,
        'year': year,
        'interests': interests ?? [],
      };

      print('📤 Request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          authToken = data['token'];
          print('✅ Token stored: $authToken');
        }

        return {
          'success': true,
          'message': 'Registration successful!',
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Logging in...');

      Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      print('📤 Request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          authToken = data['token'];
          print('✅ Login successful - Token stored: $authToken');
        }

        return {
          'success': true,
          'message': 'Login successful!',
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static void logout() {
    authToken = null;
    print('👋 Logged out - Token cleared');
  }

  static String? getAuthToken() {
    return authToken;
  }
}
