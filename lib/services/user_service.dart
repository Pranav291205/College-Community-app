import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; 

import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

class UserService {
  static Future<List<dynamic>> getRecommendedUsers() async {
    try {
      print('📥 Fetching recommended users...');
      print('   URL: $apiUrl/api/users/recommended');

      final token = PostService.authToken;

      final response = await http.get(
        Uri.parse('$apiUrl/api/users/recommended'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ Request timeout after 30 seconds');
          print('   Trying fallback endpoint...');
          throw TimeoutException('Request took too long');
        },
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> users = [];

        if (data['recommended_users'] is List) {
          users = data['recommended_users'];
        } else if (data['users'] is List) {
          users = data['users'];
        } else if (data is List) {
          users = data;
        }

        print('✅ ${users.length} users fetched');
        return users;
      } else {
        print('❌ Error: ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      print('   Falling back to getAllUsers()...');
      return getAllUsers();
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }
  static Future<List<dynamic>> getAllUsers() async {
    try {
      print('📥 Fetching all users (fallback)...');
      print('   URL: $apiUrl/api/users');

      final token = PostService.authToken;

      final response = await http.get(
        Uri.parse('$apiUrl/api/users'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> users = [];

        if (data['users'] is List) {
          users = data['users'];
        } else if (data is List) {
          users = data;
        }

        print('✅ ${users.length} users fetched (fallback)');
        return users;
      } else {
        print('❌ Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in fallback: $e');
      return [];
    }
  }
}
