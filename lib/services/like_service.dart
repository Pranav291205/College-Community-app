import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'post_service.dart';

class LikeService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';

  static Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final token = PostService.authToken;
      
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('👍 Liking post: $postId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Like Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Post liked successfully!');
        return {
          'success': true,
          'data': data,
          'likes': data['likes'] ?? 0,
        };
      } else {
        print('❌ Failed: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to like post'
          };
        } catch (e) {
          return {'success': false, 'message': 'Failed to like post'};
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unlikePost(String postId) async {
    try {
      final token = PostService.authToken;
      
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('👎 Unliking post: $postId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/unlike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Unlike Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Post unliked successfully!');
        return {
          'success': true,
          'data': data,
          'likes': data['likes'] ?? 0,
        };
      } else {
        print('❌ Failed: ${response.body}');
        return {'success': false, 'message': 'Failed to unlike post'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPostLikes(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$postId/likes'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'likes': data['likes'] ?? 0,
          'likedBy': data['likedBy'] ?? [],
        };
      }
      return {'success': false, 'likes': 0};
    } catch (e) {
      print('❌ Error fetching likes: $e');
      return {'success': false, 'likes': 0};
    }
  }
}
