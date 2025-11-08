import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

final likedPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('❤️ Fetching liked posts...');

  try {
    final token = PostService.authToken;

    if (token == null || token.isEmpty) {
      print('❌ No auth token');
      return [];
    }

    // Get all posts
    final postsResponse = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {'Accept': 'application/json'},
    );

    if (postsResponse.statusCode != 200) {
      print('❌ Failed to fetch posts');
      return [];
    }

    final postsData = jsonDecode(postsResponse.body);
    List<dynamic> allPosts = postsData is List
        ? postsData
        : postsData['posts'] ?? postsData['data'] ?? [];

    final likedResponse = await http.get(
      Uri.parse('$apiUrl/api/posts/user/liked'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (likedResponse.statusCode != 200) {
      print('⚠️ Could not fetch user liked posts endpoint, filtering manually');
      
      List<dynamic> likedPosts = [];
      for (var post in allPosts) {
        if (post is Map) {
          List likes = post['likes'] is List ? post['likes'] : [];
        }
      }
      return likedPosts;
    }

    final likedData = jsonDecode(likedResponse.body);
    List<dynamic> likedPosts = likedData['posts'] ?? likedData['data'] ?? [];

    likedPosts = likedPosts.map((post) {
      if (post is Map) {
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
      }
      return post;
    }).toList();

    print('✅ ${likedPosts.length} liked posts found');
    return likedPosts;
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});
