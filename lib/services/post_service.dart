import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';
const storage = FlutterSecureStorage();

class PostService {
  static String? _authToken;
  static bool _isGuest = false;

  static Future<void> initialize() async {
    _authToken = await storage.read(key: 'auth_token');
    _isGuest = false;
    print('✅ PostService initialized');
  }

  static String? get authToken => _authToken;
  static bool get isGuest => _isGuest;
  static bool get isLoggedIn => _authToken != null && !_isGuest;

  static void setGuestMode() {
    _isGuest = true;
    _authToken = null;
  }

  static void clearGuestMode() {
    _isGuest = false;
  }

  static Future<void> saveToken(String token) async {
    _authToken = token;
    _isGuest = false;
    await storage.write(key: 'auth_token', value: token);
  }

  static Future<void> clearToken() async {
    _authToken = null;
    _isGuest = false;
    await storage.delete(key: 'auth_token');
  }

  static void setAuthToken(String? token) {
    if (token != null) {
      saveToken(token);
    }
  }

  static void clearAuthToken() {
    _authToken = null;
    storage.delete(key: 'auth_token');
  }

  static String? getAuthToken() {
    return _authToken;
  }

  static void debugPostStructure(dynamic post) {
    print('\n🔍 ===== POST STRUCTURE DEBUG =====');
    if (post is Map) {
      print('📋 Post Keys: ${post.keys.toList()}');
      print('📌 _id: ${post['_id']}');
      print('📌 userId: ${post['userId']}');
      print('📌 author: ${post['author']}');
      print('📌 authorId: ${post['authorId']}');
      print('📌 mediaUrl: ${post['mediaUrl']}');
      print('📌 mediaType: ${post['mediaType']}');
      print('📌 title: ${post['title']}');
      if (post['author'] is Map) {
        print('📌 author._id: ${post['author']['_id']}');
      }
      print('🔍 ===== END DEBUG =====\n');
    }
  }

  static String _extractUserId(dynamic post) {
    if (post is Map) {
      String? userId = post['userId'] ??
          post['authorId'] ??
          (post['author'] is Map ? post['author']['_id'] : null) ??
          (post['author'] is Map ? post['author']['userId'] : null) ??
          '';
      return userId.toString();
    }
    return '';
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String description,
    required String category,
    File? mediaFile,
  }) async {
    try {
      print('🚀 Creating post...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/api/posts/create'),
      );

      if (_authToken != null && _authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      request.headers['Accept'] = 'application/json';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (mediaFile != null) {
        int fileSize = await mediaFile.length();
        double fileSizeMB = fileSize / (1024 * 1024);
        if (fileSizeMB > 10) {
          return {'success': false, 'message': 'File too large (max 10MB)'};
        }
        String fileName = mediaFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath('media', mediaFile.path,
              filename: fileName),
        );
      }

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Post created successfully');
        return {
          'success': true,
          'message': 'Post created!',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> getAllPosts() async {
    try {
      final headers = {'Accept': 'application/json'};
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      print('📥 Fetching all posts...');

      final endpoints = [
        '$apiUrl/api/posts',
        '$apiUrl/api/posts/feed',
        '$apiUrl/api/posts/all',
      ];

      for (String endpoint in endpoints) {
        print('🔍 Trying: $endpoint');

        try {
          final response = await http
              .get(
                Uri.parse(endpoint),
                headers: headers,
              )
              .timeout(const Duration(seconds: 30));

          print('📊 Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List<dynamic> posts = [];

            if (data is List) {
              posts = data;
            } else if (data is Map) {
              posts = data['posts'] ?? data['data'] ?? data['feed'] ?? [];
            }

            for (int i = 0; i < posts.length; i++) {
              if (posts[i] is Map) {
                Map<String, dynamic> post =
                    Map<String, dynamic>.from(posts[i]);

                if (post['authorName'] == null ||
                    (post['authorName'] is String &&
                        post['authorName'].isEmpty)) {
                  if (post['author'] is Map) {
                    post['authorName'] = post['author']['name'] ??
                        post['author']['userName'] ??
                        post['author']['fullName'] ??
                        'Anonymous';
                  } else if (post['author'] is String &&
                      post['author'].isNotEmpty) {
                    post['authorName'] = post['author'];
                  } else if (post['userName'] is String &&
                      post['userName'].isNotEmpty) {
                    post['authorName'] = post['userName'];
                  } else {
                    post['authorName'] = 'Anonymous';
                  }
                }

                posts[i] = post;
              }
            }

            print('✅ ${posts.length} posts fetched from $endpoint');
            if (posts.isNotEmpty) {
              debugPostStructure(posts[0]);
            }
            return posts;
          }
        } catch (e) {
          print('   ⚠️ Failed on $endpoint: $e');
          continue;
        }
      }

      print('❌ All endpoints failed for posts');
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getUserPosts() async {
    try {
      final token = authToken;
      if (token == null) {
        print('❌ No token - getUserPosts');
        return [];
      }

      print('📥 Fetching user posts...');

      final endpoints = [
        '$apiUrl/api/users/me/posts',
        '$apiUrl/api/posts/me',
        '$apiUrl/api/posts/user/me',
        '$apiUrl/api/users/posts',
        '$apiUrl/api/posts/user',
      ];

      for (String endpoint in endpoints) {
        print('🔍 Trying: $endpoint');

        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 30));

          print('📊 Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List<dynamic> userPosts = [];

            if (data is List) {
              userPosts = data;
            } else if (data is Map) {
              userPosts = data['posts'] ??
                  data['userPosts'] ??
                  data['data'] ??
                  data['myPosts'] ??
                  [];
            }

            print('✅ ${userPosts.length} user posts fetched from $endpoint');

            for (int i = 0; i < userPosts.length; i++) {
              if (userPosts[i] is Map) {
                Map<String, dynamic> post =
                    Map<String, dynamic>.from(userPosts[i]);

                if (post['authorName'] == null ||
                    (post['authorName'] is String &&
                        post['authorName'].isEmpty)) {
                  if (post['author'] is Map) {
                    post['authorName'] = post['author']['name'] ??
                        post['author']['userName'] ??
                        post['author']['fullName'] ??
                        'You';
                  } else if (post['author'] is String &&
                      post['author'].isNotEmpty) {
                    post['authorName'] = post['author'];
                  } else if (post['userName'] is String &&
                      post['userName'].isNotEmpty) {
                    post['authorName'] = post['userName'];
                  } else {
                    post['authorName'] = 'You';
                  }
                }

                userPosts[i] = post;
              }
            }

            return userPosts;
          }
        } catch (e) {
          print('   ⚠️ Failed on $endpoint: $e');
          continue;
        }
      }

      print('❌ All endpoints failed for user posts');
      return [];
    } catch (e) {
      print('❌ Error fetching user posts: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserEngagement() async {
    try {
      final token = authToken;
      if (token == null) {
        print('❌ No token - getUserEngagement');
        return {
          'success': false,
          'likedPosts': [],
          'dislikedPosts': [],
          'commentedPosts': [],
        };
      }

      print('📥 Fetching user engagement...');

      final response = await http.get(
        Uri.parse('$apiUrl/api/users/engagement'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Engagement Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final user = data['user'] ?? {};
          final likedPosts = user['likedPosts'] ?? [];
          final dislikedPosts = user['dislikedPosts'] ?? [];
          final commentedPosts = user['commentedPosts'] ?? [];

          print('✅ Liked: ${likedPosts.length}, Disliked: ${dislikedPosts.length}, Commented: ${commentedPosts.length}');

          return {
            'success': true,
            'likedPosts': likedPosts,
            'dislikedPosts': dislikedPosts,
            'commentedPosts': commentedPosts,
          };
        }
      }

      return {
        'success': false,
        'likedPosts': [],
        'dislikedPosts': [],
        'commentedPosts': [],
      };
    } catch (e) {
      print('❌ Error fetching engagement: $e');
      return {
        'success': false,
        'likedPosts': [],
        'dislikedPosts': [],
        'commentedPosts': [],
      };
    }
  }

  static Future<List<dynamic>> getLikedPosts() async {
    try {
      final engagement = await getUserEngagement();
      final likedPosts = engagement['likedPosts'] ?? [];

      print('✅ ${likedPosts.length} liked posts fetched');

      for (int i = 0; i < likedPosts.length; i++) {
        if (likedPosts[i] is Map) {
          Map<String, dynamic> post = Map<String, dynamic>.from(likedPosts[i]);

          if (post['authorName'] == null ||
              (post['authorName'] is String &&
                  post['authorName'].isEmpty)) {
            if (post['author'] is Map) {
              post['authorName'] = post['author']['name'] ??
                  post['author']['userName'] ??
                  post['author']['fullName'] ??
                  'Anonymous';
            }
          }

          likedPosts[i] = post;
        }
      }

      return likedPosts;
    } catch (e) {
      print('❌ Error fetching liked posts: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getCommentedPosts() async {
    try {
      final engagement = await getUserEngagement();
      final commentedPosts = engagement['commentedPosts'] ?? [];

      print('✅ ${commentedPosts.length} commented posts fetched');

      for (int i = 0; i < commentedPosts.length; i++) {
        if (commentedPosts[i] is Map) {
          Map<String, dynamic> post =
              Map<String, dynamic>.from(commentedPosts[i]);

          if (post['authorName'] == null ||
              (post['authorName'] is String &&
                  post['authorName'].isEmpty)) {
            if (post['author'] is Map) {
              post['authorName'] = post['author']['name'] ??
                  post['author']['userName'] ??
                  post['author']['fullName'] ??
                  'Anonymous';
            }
          }

          commentedPosts[i] = post;
        }
      }

      return commentedPosts;
    } catch (e) {
      print('❌ Error fetching commented posts: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getDislikedPosts() async {
    try {
      final engagement = await getUserEngagement();
      final dislikedPosts = engagement['dislikedPosts'] ?? [];

      print('✅ ${dislikedPosts.length} disliked posts fetched');

      for (int i = 0; i < dislikedPosts.length; i++) {
        if (dislikedPosts[i] is Map) {
          Map<String, dynamic> post =
              Map<String, dynamic>.from(dislikedPosts[i]);

          if (post['authorName'] == null ||
              (post['authorName'] is String &&
                  post['authorName'].isEmpty)) {
            if (post['author'] is Map) {
              post['authorName'] = post['author']['name'] ??
                  post['author']['userName'] ??
                  post['author']['fullName'] ??
                  'Anonymous';
            }
          }

          dislikedPosts[i] = post;
        }
      }

      return dislikedPosts;
    } catch (e) {
      print('❌ Error fetching disliked posts: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final headers = {'Accept': 'application/json'};
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      print('🔍 Fetching post: $postId');

      final response = await http.get(
        Uri.parse('$apiUrl/api/posts/$postId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('✏️ Updating post: $postId');

      final response = await http.put(
        Uri.parse('$apiUrl/api/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Post updated');
        return {'success': true, 'message': 'Post updated successfully'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('🗑️ Deleting post: $postId');

      final response = await http.delete(
        Uri.parse('$apiUrl/api/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Delete Status: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        print('✅ Post deleted successfully');
        return {'success': true, 'message': 'Post deleted successfully'};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Only post owner can delete',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Forbidden - You cannot delete this post',
        };
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('❤️ Liking post: $postId');

      final response = await http.post(
        Uri.parse('$apiUrl/api/posts/$postId/like'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Post liked');
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Post liked',
          'likes': responseData['likes'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> unlikePost(String postId) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('🤍 Unliking post: $postId');

      final response = await http.post(
        Uri.parse('$apiUrl/api/posts/$postId/unlike'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Post unliked');
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Post unliked',
          'likes': responseData['likes'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('💬 Adding comment to post: $postId');

      final response = await http.post(
        Uri.parse('$apiUrl/api/posts/$postId/comment'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'content': content}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Comment added');
        return {'success': true, 'message': 'Comment added'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('🗑️ Deleting comment: $commentId from post: $postId');

      final response = await http.delete(
        Uri.parse('$apiUrl/api/posts/$postId/comment/$commentId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        print('✅ Comment deleted');
        return {'success': true, 'message': 'Comment deleted'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> searchPosts(String query) async {
    try {
      final headers = {'Accept': 'application/json'};
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      print('🔍 Searching posts: $query');

      final response = await http.get(
        Uri.parse('$apiUrl/api/posts/search?q=$query'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> posts = [];

        if (data is List) {
          posts = data;
        } else if (data is Map) {
          posts = data['posts'] ?? data['data'] ?? [];
        }

        print('✅ ${posts.length} results found');
        return posts;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}
