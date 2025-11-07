import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'post_service.dart';

const String chatApiUrl = 'https://college-community-app-backend.onrender.com';
const Duration apiTimeout = Duration(seconds: 10);

class ChatService {
  static Future<Map<String, dynamic>> createGroup({
    required String chatName,
    required List<String> users,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('📤 Creating group: $chatName');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/chat/group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': chatName, 
          'users': users,
        }),
      ).timeout(apiTimeout);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Group created');
        return {'success': true, 'message': 'Group created'};
      }
      return {'success': false, 'message': 'Failed to create group'};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      print('📤 Adding user to group');

      final response = await http.put(
        Uri.parse('$chatApiUrl/api/chat/group/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chatId': groupId,
          'userId': userId,
        }),
      ).timeout(apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User added');
        return {'success': true, 'message': 'User added'};
      }
      return {'success': false, 'message': 'Failed to add user'};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      print('🗑️ Removing user from group');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/chat/group/remove'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': groupId,
          'userId': userId,
        }),
      ).timeout(apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User removed');
        return {'success': true, 'message': 'User removed'};
      }
      return {'success': false, 'message': 'Failed to remove user'};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    try {
      final token = PostService.authToken;
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      print('👋 Leaving group');

      String? userId;
      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        userId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
      } catch (e) {
        print('❌ Token decode error: $e');
        return {'success': false, 'message': 'Could not identify user'};
      }

      if (userId == null) {
        return {'success': false, 'message': 'User not found'};
      }

      final result = await removeUserFromGroup(
        groupId: groupId,
        userId: userId,
      );

      return result;
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      print('📤 Sending message');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/message/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': content}),
      ).timeout(apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Message sent');
        return {'success': true, 'message': 'Message sent'};
      }
      print('❌ Send failed: ${response.statusCode}');
      return {'success': false, 'message': 'Failed to send'};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> getGroupMessages(String messageId) async {
    try {
      final token = PostService.authToken;
      if (token == null) return [];

      print('💬 Fetching messages...');

      final response = await http.get(
        Uri.parse('$chatApiUrl/api/message/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(apiTimeout);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          print('✅ ${data.length} messages');
          return data;
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          
          if (map['messages'] is List) return map['messages'];
          if (map['data'] is List) return map['data'];
        }
      }

      print('⚠️ No messages');
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getChatGroups() async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        print('❌ No token');
        return [];
      }

      print('📥 Fetching groups...');

      final response = await http.get(
        Uri.parse('$chatApiUrl/api/chat/group'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(apiTimeout);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          print('✅ ${data.length} groups found');
          return data;
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          
          if (map['groups'] is List) {
            print('✅ ${map['groups'].length} groups found');
            return map['groups'];
          }
          if (map['data'] is List) {
            print('✅ ${map['data'].length} groups found');
            return map['data'];
          }
        }
      }

      print('⚠️ No groups');
      return [];
    } catch (e) {
      print('❌ Error fetching groups: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getChatGroup(String groupId) async {
    try {
      print('🔍 Getting group: $groupId');
      
      final groups = await getChatGroups();
      
      if (groups.isEmpty) {
        print('❌ No groups available');
        return null;
      }

      for (var g in groups) {
        if (g is Map) {
          final group = Map<String, dynamic>.from(g);
          final id = group['_id'] ?? group['id'];
          
          if (id == groupId) {
            print('✅ Group found');
            return group;
          }
        }
      }

      print('❌ Group not found');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getGroupMembers(String groupId) async {
    try {
      print('👥 Getting members for: $groupId');
      
      final group = await getChatGroup(groupId);
      
      if (group == null) {
        print('❌ Group not found');
        return [];
      }
      if (group['users'] is List) {
        print('✅ ${group['users'].length} members');
        return group['users'];
      }
      if (group['members'] is List) {
        print('✅ ${group['members'].length} members');
        return group['members'];
      }

      print('⚠️ No members found');
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}
