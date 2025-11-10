import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'post_service.dart';

class CommentService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';

  static Future<Map<String, dynamic>> addComment(post, String trim, {
    required String postId,
    required String text,
  }) async {
    try {
      final token = PostService.authToken;
      
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      String spamCheck = _checkSpamLocally(text);
      if (spamCheck.isNotEmpty) {
        print('⚠️ Local spam detected: $spamCheck');
        return {
          'success': false,
          'message': 'Your comment contains inappropriate content: $spamCheck'
        };
      }

      String? userId;
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken['userId'] ?? 
                 decodedToken['id'] ?? 
                 decodedToken['_id'];
      } catch (e) {
        print('❌ Failed to decode token: $e');
        return {'success': false, 'message': 'Invalid token'};
      }

      if (userId == null || userId.isEmpty) {
        return {'success': false, 'message': 'User ID not found'};
      }

      print('💬 Adding comment to post: $postId');

      final requestBody = {
        'postId': postId,
        'user': userId,
        'text': text,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/comments/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Comment Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['spam'] == true || data['spamLabel'] != 'Normal') {
          print('🚫 Spam detected by backend!');
          print('   Spam Score: ${data['spamScore']}');
          print('   Spam Label: ${data['spamLabel']}');
          
          return {
            'success': false,
            'message': 'Your comment was flagged as ${data['spamLabel']}. Please try again with different wording.',
            'isSpam': true,
          };
        }

        print('✅ Comment added successfully!');
        return {'success': true, 'data': data};
      } else {
        print('❌ Failed: ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to add comment'
          };
        } catch (e) {
          return {'success': false, 'message': 'Failed to add comment'};
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static String _checkSpamLocally(String text) {
    final spamPatterns = [
      RegExp(r'fuck|shit|asshole|bitch|damn|crap', caseSensitive: false),
      RegExp(r'kill|die|suicide|hate', caseSensitive: false),
      RegExp(r'porn|xxx|sex|nude', caseSensitive: false),
      RegExp(r'viagra|casino|lottery|free money', caseSensitive: false),
    ];

    for (var pattern in spamPatterns) {
      if (pattern.hasMatch(text)) {
        return 'Inappropriate language detected';
      }
    }

    if (text.length > 5) {
      int capsCount = text.split('').where((c) => c == c.toUpperCase() && c != c.toLowerCase()).length;
      double capsPercentage = (capsCount / text.length) * 100;
      if (capsPercentage > 80) {
        return 'Too many capital letters';
      }
    }

    if (RegExp(r'http|www|\.com|\.net').hasMatch(text)) {
      return 'Links not allowed';
    }

    return ''; 
  }

  static Future<List<dynamic>> getPostComments(String postId) async {
    try {
      print('📥 Fetching comments for post: $postId');
      
      final endpoints = [
        '$baseUrl/api/comments/$postId',
        '$baseUrl/api/comments/post/$postId',
        '$baseUrl/api/posts/$postId/comments',
      ];

      for (final endpoint in endpoints) {
        print('🔍 Trying: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {'Accept': 'application/json'},
        );

        print('   Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          List<dynamic> comments = [];
          
          if (data is List) {
            comments = data;
          } else if (data is Map) {
            comments = data['comments'] ?? 
                      data['data'] ?? 
                      data['results'] ?? 
                      [];
          }

          comments = comments.where((comment) {
            if (comment is Map) {
              if (comment['spam'] == true) {
                print('   ⚠️ Skipping spam comment: ${comment['spamLabel']}');
                return false;
              }
              if (comment['spamLabel'] != null && comment['spamLabel'] != 'Normal') {
                print('   ⚠️ Skipping ${comment['spamLabel']} comment');
                return false;
              }
            }
            return true;
          }).map((comment) {
            if (comment is Map) {
              Map<String, dynamic> updatedComment = Map.from(comment);
              
              if (comment['user'] is Map) {
                updatedComment['userName'] = comment['user']['name'] ?? 'Anonymous';
              } else {
                updatedComment['userName'] = 'Anonymous';
              }
              
              return updatedComment;
            }
            return comment;
          }).toList();

          print('✅ ${comments.length} comments fetched (spam filtered)');
          return comments;
        }
      }

      print('❌ No endpoint returned comments');
      return [];
    } catch (e) {
      print('❌ Error fetching comments: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getAllCommentsForPost(String postId) async {
    try {
      print('📥 Fetching all comments and filtering...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/comments'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> allComments = data is List ? data : data['comments'] ?? data['data'] ?? [];
        
        List<dynamic> postComments = allComments.where((comment) {
          if (comment is Map) {
            if (comment['spam'] == true || (comment['spamLabel'] != null && comment['spamLabel'] != 'Normal')) {
              return false;
            }

            String commentPostId = '';
            if (comment['post'] is String) {
              commentPostId = comment['post'];
            } else if (comment['post'] is Map) {
              commentPostId = comment['post']['_id'] ?? '';
            }
            return commentPostId == postId;
          }
          return false;
        }).map((comment) {
          Map<String, dynamic> updatedComment = Map.from(comment);
          if (comment['user'] is Map) {
            updatedComment['userName'] = comment['user']['name'] ?? 'Anonymous';
          } else {
            updatedComment['userName'] = 'Anonymous';
          }
          return updatedComment;
        }).toList();

        print('✅ ${postComments.length} non-spam comments found');
        return postComments;
      }
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}
