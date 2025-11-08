import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchService {
  static const String userSearchUrl = 'https://user-search-vw9w.onrender.com/smart_user_search/';
  static const String postSearchUrl = 'https://post-search-yh1s.onrender.com/search_posts_by_title/';

  static Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      print('🔍 Searching users: $query');

      final response = await http.get(
        Uri.parse('$userSearchUrl?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('✅ Users found: ${data.length ?? 0}');
        
        if (data is List) {
          return {
            'success': true,
            'users': data,
            'count': data.length,
          };
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          if (map['results'] is List) {
            return {
              'success': true,
              'users': map['results'],
              'count': map['results'].length,
            };
          }
          return {
            'success': true,
            'users': data,
            'count': 1,
          };
        }
        
        return {
          'success': true,
          'users': [],
          'count': 0,
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'users': [],
        };
      }
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
      print('🔍 Searching posts: $query');

      final response = await http.get(
        Uri.parse('$postSearchUrl?title=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('✅ Posts found: ${data.length ?? 0}');
        
        if (data is List) {
          return {
            'success': true,
            'posts': data,
            'count': data.length,
          };
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          if (map['results'] is List) {
            return {
              'success': true,
              'posts': map['results'],
              'count': map['results'].length,
            };
          }
          return {
            'success': true,
            'posts': data,
            'count': 1,
          };
        }
        
        return {
          'success': true,
          'posts': [],
          'count': 0,
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'posts': [],
        };
      }
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
