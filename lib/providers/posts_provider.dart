import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

// ✅ Get current user ID from JWT token
final currentUserIdProvider = Provider<String?>((ref) {
  final token = PostService.authToken;
  if (token != null && token.isNotEmpty) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? userId = decodedToken['userId'] ?? 
                       decodedToken['id'] ?? 
                       decodedToken['_id'] ??
                       decodedToken['sub'];
      print('🔑 Current User ID from token: $userId');
      return userId;
    } catch (e) {
      print('❌ Token decode error: $e');
      return null;
    }
  }
  return null;
});

// ✅ ALL POSTS (for home screen)
final postsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('📥 Fetching all posts for HOME SCREEN...');

  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> posts = data is List ? data : data['posts'] ?? data['data'] ?? [];

      posts = posts.map((post) {
        if (post is! Map) return post;
        Map<String, dynamic> updatedPost = Map.from(post);

        String authorName = 'Anonymous';
        if (post['user'] is Map) {
          authorName = post['user']['name'] ?? 'Anonymous';
        }
        updatedPost['authorName'] = authorName;

        if (updatedPost['mediaUrl'] != null) {
          String url = updatedPost['mediaUrl'].toString().trim();
          if (url.startsWith('/')) {
            updatedPost['mediaUrl'] = '$apiUrl$url';
          }
        }

        return updatedPost;
      }).toList();

      print('✅ ${posts.length} posts fetched for home screen');
      return posts;
    }
    return [];
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});

// ✅ USER'S OWN POSTS (for profile - FILTERED BY CURRENT USER ID)
final userPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('📥 Fetching user posts for PROFILE...');

  try {
    final token = PostService.authToken;
    final currentUserId = ref.watch(currentUserIdProvider);

    print('📌 DEBUG INFO:');
    print('   Token exists: ${token != null && token.isNotEmpty}');
    print('   Current User ID: $currentUserId');

    if (token == null || token.isEmpty) {
      print('❌ No auth token');
      return [];
    }

    if (currentUserId == null) {
      print('❌ No current user ID');
      return [];
    }

    // Fetch all posts
    final response = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> allPosts = data is List ? data : data['posts'] ?? data['data'] ?? [];

      print('📋 Total posts from API: ${allPosts.length}');

      // ✅ FILTER: Keep only posts where user._id matches current user ID
      List<dynamic> userPosts = [];
      
      for (var post in allPosts) {
        if (post is Map && post['user'] is Map) {
          String postUserId = post['user']['_id'] ?? '';
          String postUserName = post['user']['name'] ?? 'Unknown';
          
          print('   Post author: $postUserName (ID: $postUserId)');
          
          // ✅ EXACT MATCH comparison
          if (postUserId.trim() == currentUserId.trim()) {
            Map<String, dynamic> updatedPost = Map.from(post);
            updatedPost['authorName'] = postUserName;

            if (updatedPost['mediaUrl'] != null) {
              String url = updatedPost['mediaUrl'].toString().trim();
              if (url.startsWith('/')) {
                updatedPost['mediaUrl'] = '$apiUrl$url';
              }
            }

            userPosts.add(updatedPost);
            print('      ✅ MATCHED - Added to user posts!');
          } else {
            print('      ❌ No match: "$postUserId" != "$currentUserId"');
          }
        }
      }

      print('✅ ${userPosts.length} user posts filtered (YOUR posts only)');
      return userPosts;
    }
    return [];
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});
