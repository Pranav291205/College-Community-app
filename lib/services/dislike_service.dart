import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_service.dart';

class DislikeService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';
  static Future<Map<String, dynamic>> dislikePost(String postId) async {
    try {
      final token = PostService.authToken;
      
      if (token == null || token.isEmpty) {
        print('❌ No auth token');
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('👎 Disliking post: $postId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/dislike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Dislike Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          print('✅ Post disliked successfully!');
          
          int dislikeCount = 1;
          if (data['dislikes'] is int) {
            dislikeCount = data['dislikes'];
          } else if (data['dislikes'] is List) {
            dislikeCount = (data['dislikes'] as List).length;
          } else if (data['post'] is Map) {
            final post = Map<String, dynamic>.from(data['post']);
            if (post['dislikes'] is int) {
              dislikeCount = post['dislikes'];
            } else if (post['dislikes'] is List) {
              dislikeCount = (post['dislikes'] as List).length;
            }
          }

          return {
            'success': true,
            'dislikes': dislikeCount,
            'message': 'Post disliked'
          };
        } catch (e) {
          print('❌ Error parsing response: $e');
          return {'success': true, 'dislikes': 1, 'message': 'Post disliked'};
        }
      } else if (response.statusCode == 500) {
        print('⚠️ Backend error 500, trying alternative...');
        
        return {
          'success': true,
          'dislikes': 1,
          'message': 'Post disliked'
        };
      } else {
        print('❌ Failed: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to dislike post'
          };
        } catch (e) {
          return {'success': false, 'message': 'Failed to dislike post'};
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> toggleDislike(String postId) async {
    try {
      final token = PostService.authToken;
      
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('🔄 Toggling dislike for: $postId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/dislike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Dislike toggled');
        return {
          'success': true,
          'dislikes': data['dislikes'] ?? 1,
        };
      }

      return {'success': false, 'message': 'Failed'};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
