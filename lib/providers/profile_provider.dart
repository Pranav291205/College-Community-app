import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Auth token provider - stores the token globally
final authTokenProvider = StateProvider<String?>((ref) => null);

// User profile provider that uses the auth token
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final baseUrl = 'https://college-community-app-backend.onrender.com';
    final token = ref.watch(authTokenProvider); // ✅ Get token from provider

    print('🔍 Token from provider: $token');

    if (token == null || token.isEmpty) {
      print('❌ No auth token found');
      return {'success': false, 'message': 'Not logged in'};
    }

    print('📍 Fetching profile from: $baseUrl/api/users/profile');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    print('📊 Status: ${response.statusCode}');
    print('📥 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Unauthorized - Please login again',
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to fetch profile: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('❌ Error: $e');
    return {'success': false, 'message': 'Connection error: $e'};
  }
});
