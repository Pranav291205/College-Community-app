import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

final commentedPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('💬 Fetching commented posts...');

  try {
    final token = PostService.authToken;

    if (token == null || token.isEmpty) {
      print('❌ No auth token');
      return [];
    }

    final postsResponse = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {'Accept': 'application/json'},
    );

    if (postsResponse.statusCode != 200) {
      return [];
    }

    final postsData = jsonDecode(postsResponse.body);
    List<dynamic> allPosts = postsData is List
        ? postsData
        : postsData['posts'] ?? postsData['data'] ?? [];

    final commentsResponse = await http.get(
      Uri.parse('$apiUrl/api/comments/user/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (commentsResponse.statusCode != 200) {
      return [];
    }

    final commentsData = jsonDecode(commentsResponse.body);
    List<dynamic> userComments = commentsData['comments'] ??
        commentsData['data'] ??
        [];

    Set<String> commentedPostIds = {};
    for (var comment in userComments) {
      if (comment['post'] is String) {
        commentedPostIds.add(comment['post']);
      } else if (comment['post'] is Map) {
        commentedPostIds.add(comment['post']['_id']);
      }
    }

    List<dynamic> commentedPosts = allPosts.where((post) {
      if (post is Map) {
        return commentedPostIds.contains(post['_id']);
      }
      return false;
    }).map((post) {
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

    print('✅ ${commentedPosts.length} commented posts found');
    return commentedPosts;
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});
