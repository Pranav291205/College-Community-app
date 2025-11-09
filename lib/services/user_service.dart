import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io'; 

import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

class UserService {
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
  try {
    if (!await imageFile.exists()) {
      print('❌ File does not exist: ${imageFile.path}');
      return {'success': false, 'message': 'Image file not found'};
    }

    final fileSize = await imageFile.length();
    print('📏 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
    
    if (fileSize > 5 * 1024 * 1024) { 
      return {'success': false, 'message': 'Image too large (max 5MB)'};
    }

    print('📸 Uploading profile image...');
    print('📂 File path: ${imageFile.path}');

    final token = PostService.authToken;

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/api/users/upload-profile'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    final multipartFile = await http.MultipartFile.fromPath(
      'profileImage', 
      imageFile.path,
    );
    
    request.files.add(multipartFile);
    
    print('📤 Sending request...');
    print('🔑 Authorization: Bearer ${token.substring(0, 20)}...');
    print('📝 Field name: profileImage');
    print('📁 File name: ${multipartFile.filename}');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);

    print('📊 Upload status: ${response.statusCode}');
    print('📥 Response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('✅ Profile image uploaded successfully!');
        return {
          'success': true,
          'message': data['message'] ?? 'Profile photo uploaded successfully',
          'imageUrl': data['imageUrl'],
          'user': data['user'],
        };
      } catch (e) {
        print('❌ Failed to parse response: $e');
        return {'success': false, 'message': 'Invalid response from server'};
      }
    } else {
      String errorMessage = 'Upload failed';
      
      if (response.body.contains('<!DOCTYPE html>')) {
        errorMessage = 'Server error (500). Check backend logs.';
      } else {
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? 'Upload failed';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
      }
      
      print('❌ Upload failed: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  } catch (e, stackTrace) {
    print('❌ Error uploading profile image: $e');
    print('Stack trace: $stackTrace');
    return {'success': false, 'message': 'Error: $e'};
  }
}

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('📥 Fetching user profile...');

      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$apiUrl/api/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Profile loaded');
        return {
          'success': true,
          'user': data['user'] ?? data,
        };
      } else {
        print('❌ Failed to load profile');
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

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
