import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

final currentUserIdProvider = Provider<String?>((ref) {
  final token = PostService.authToken;
  if (token != null && token.isNotEmpty) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String? userId = decodedToken['userId'] ?? 
                       decodedToken['id'] ?? 
                       decodedToken['_id'] ??
                       decodedToken['sub'];
      print('🔑 Current User ID: $userId');
      return userId;
    } catch (e) {
      print('❌ Token decode error: $e');
      return null;
    }
  }
  return null;
});

final postsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('\n📥 ===== FETCHING ALL POSTS (DEBUG) =====');
  
  try {
    List<dynamic> posts = [];
    List<String> endpoints = [
      '$apiUrl/api/posts/feed',
      '$apiUrl/api/posts/all',
    ];

    for (String endpoint in endpoints) {
      print('🔍 Trying: $endpoint');
      
      try {
        var response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Accept': 'application/json',
            if (PostService.authToken != null) 'Authorization': 'Bearer ${PostService.authToken}',
          },
        ).timeout(const Duration(seconds: 10));

        print('   Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          posts = _extractPosts(data);
          
          if (posts.isNotEmpty) {
            print('   ✅ SUCCESS! Found ${posts.length} posts');
            break;
          }
        }
      } catch (e) {
        print('   ❌ Failed: $e');
      }
    }

    posts = posts.map((post) {
      if (post is! Map) return post;
      Map<String, dynamic> updatedPost = Map.from(post);

      String authorName = 'Anonymous';
      if (post['user'] is Map) {
        authorName = post['user']['name'] ?? post['user']['userName'] ?? 'Anonymous';
      } else if (post['authorName'] is String && post['authorName'].isNotEmpty) {
        authorName = post['authorName'];
      }
      updatedPost['authorName'] = authorName;

      if (updatedPost['mediaUrl'] != null) {
        String url = updatedPost['mediaUrl'].toString().trim();
        if (url.isNotEmpty && !url.startsWith('http')) {
          updatedPost['mediaUrl'] = '$apiUrl$url';
        }
      }

      return updatedPost;
    }).toList();

    print('✅ Final posts count: ${posts.length}');
    print('📥 ===== END FETCH =====\n');
    return posts;
  } catch (e) {
    print('❌ FATAL Error: $e');
    print('📥 ===== END FETCH (ERROR) =====\n');
    return [];
  }
});

final userPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('\n📥 ===== FETCHING USER POSTS (DEBUG) =====');

  try {
    final token = PostService.authToken;
    final currentUserId = ref.watch(currentUserIdProvider);

    print('🔐 Token: ${token != null ? "✅ exists" : "❌ null"}');
    print('👤 User ID: ${currentUserId ?? "❌ null"}');

    if (token == null || currentUserId == null) {
      print('❌ Missing credentials');
      return [];
    }

    var response = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('📊 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> allPosts = _extractPosts(data);

      print('📋 Total posts from server: ${allPosts.length}');

      List<dynamic> userPosts = [];
      
      for (var post in allPosts) {
        if (post is! Map) continue;

        String postUserId = '';
        String postUserName = 'Unknown';

        if (post['user'] is Map) {
          postUserId = post['user']['_id'] ?? '';
          postUserName = post['user']['name'] ?? 'Unknown';
        } else if (post['userId'] is String) {
          postUserId = post['userId'];
        }

        bool isMatch = postUserId.trim() == currentUserId.trim();
        print('   Post: "$postUserName" → ${isMatch ? "✅ MATCH" : "❌ no match"}');

        if (isMatch) {
          Map<String, dynamic> updatedPost = Map.from(post);
          updatedPost['authorName'] = postUserName;
          userPosts.add(updatedPost);
        }
      }

      print('✅ User posts: ${userPosts.length}');
      print('📥 ===== END FETCH =====\n');
      return userPosts;
    }

    print('❌ Failed with status: ${response.statusCode}');
    return [];
  } catch (e) {
    print('❌ Exception: $e');
    print('📥 ===== END FETCH (ERROR) =====\n');
    return [];
  }
});

List<dynamic> _extractPosts(dynamic data) {
  if (data is List) return data;
  if (data is Map) {
    if (data['posts'] is List) return data['posts'];
    if (data['data'] is List) return data['data'];
    if (data['message'] is List) return data['message'];
  }
  return [];
}
