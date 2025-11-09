import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SearchService {
  static const String userSearchUrl = 'https://user-search-vw9w.onrender.com/smart_user_search/';
  static const String postSearchUrl = 'https://post-search-yh1s.onrender.com/search_posts_by_title/';

  static Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      print('🔍 Searching users: "$query"');

      final response = await http.post(
        Uri.parse(userSearchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': query}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout. Service may be starting up.');
        },
      );

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Data type: ${data.runtimeType}');

        if (data is List) {
          print('✅ Found ${data.length} users (List)');
          return {
            'success': true,
            'users': data,
            'count': data.length,
          };
        }
        
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          
          if (map['results'] is List) {
            print('✅ Found ${map['results'].length} users (results field)');
            return {
              'success': true,
              'users': map['results'],
              'count': map['results'].length,
            };
          }
          
          if (map['users'] is List) {
            print('✅ Found ${map['users'].length} users (users field)');
            return {
              'success': true,
              'users': map['users'],
              'count': map['users'].length,
            };
          }
          
          print('✅ Found 1 user (single object)');
          return {
            'success': true,
            'users': [data],
            'count': 1,
          };
        }

        print('⚠️ No users found');
        return {
          'success': true,
          'users': [],
          'count': 0,
        };
      } else if (response.statusCode == 422) {
        print('❌ Validation error: ${response.body}');
        return {
          'success': false,
          'message': 'Invalid search query',
          'users': [],
        };
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'users': [],
        };
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      return {
        'success': false,
        'message': 'Service is starting up. Please try again in a moment.',
        'users': [],
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'users': [],
      };
    }
  }

  static Future<Map<String, dynamic>> searchPosts(String query) async {
    try {
      print('🔍 Searching posts: "$query"');

      final response = await http.post(
        Uri.parse(postSearchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'query': query}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout. Service may be starting up.');
        },
      );

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Data type: ${data.runtimeType}');

        if (data is List) {
          print('✅ Found ${data.length} posts (List)');
          return {
            'success': true,
            'posts': data,
            'count': data.length,
          };
        }
        
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          
          if (map['results'] is List) {
            print('✅ Found ${map['results'].length} posts (results field)');
            return {
              'success': true,
              'posts': map['results'],
              'count': map['results'].length,
            };
          }
          
          if (map['posts'] is List) {
            print('✅ Found ${map['posts'].length} posts (posts field)');
            return {
              'success': true,
              'posts': map['posts'],
              'count': map['posts'].length,
            };
          }
          
          print('✅ Found 1 post (single object)');
          return {
            'success': true,
            'posts': [data],
            'count': 1,
          };
        }

        print('⚠️ No posts found');
        return {
          'success': true,
          'posts': [],
          'count': 0,
        };
      } else if (response.statusCode == 422) {
        print('❌ Validation error: ${response.body}');
        return {
          'success': false,
          'message': 'Invalid search query',
          'posts': [],
        };
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'posts': [],
        };
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      return {
        'success': false,
        'message': 'Service is starting up. Please try again in a moment.',
        'posts': [],
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'posts': [],
      };
    }
  }
}
