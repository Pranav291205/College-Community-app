import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'post_service.dart';

const String chatApiUrl = 'https://college-community-app-backend.onrender.com';
const Duration apiTimeout = Duration(seconds: 10);

class ChatService {
  static Future<Map<String, dynamic>> getOrCreateDirectChat(String userId) async {
    try {
      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        print('❌ No auth token');
        return {
          'success': false,
          'message': 'Not authenticated',
          'chat': null,
        };
      }

      print('💬 Getting or creating direct chat with user: $userId');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/chat/access'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true || data['_id'] != null) {
          final chatData = data is Map ? data : {};

          print('✅ Chat loaded:');
          print('   ID: ${chatData['_id']}');
          print('   Name: ${chatData['chatName']}');
          print('   Users: ${chatData['users']?.length ?? 0}');

          return {
            'success': true,
            'message': 'Chat loaded successfully',
            'chat': chatData,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to load chat',
            'chat': null,
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Token expired',
          'chat': null,
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'chat': null,
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'chat': null,
      };
    }
  }
  static Future<Map<String, dynamic>> fetchChats() async {
  try {
    final token = PostService.authToken;

    if (token == null || token.isEmpty) {
      print('❌ No auth token');
      return {
        'success': false,
        'message': 'Not authenticated',
        'chats': [],
      };
    }

    print('📥 Fetching all chats...');

    final response = await http.get(
      Uri.parse('$chatApiUrl/api/chat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    print('📊 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> chats = [];

      if (data is List) {
        chats = data;
      } else if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['chats'] is List) {
          chats = map['chats'];
        } else if (map['data'] is List) {
          chats = map['data'];
        }
      }

      print('✅ ${chats.length} raw chats fetched');

      String? currentUserId;
      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        currentUserId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
      } catch (e) {
        print('⚠️ Could not decode token: $e');
      }

      List<Map<String, dynamic>> processedChats = [];
      for (var chat in chats) {
        if (chat is Map) {
          Map<String, dynamic> chatData = Map<String, dynamic>.from(chat);
          final chatId = chatData['_id'] ?? chatData['id'] ?? '';

          if (chatId.isEmpty) {
            print('⚠️ WARNING: Chat has no ID, skipping');
            continue;
          }

          var chatName = chatData['chatName'] ?? chatData['name'] ?? 'Chat';
          final isGroupChat = chatData['isGroupChat'] ?? false;
          final users = chatData['users'] ?? [];

           String? currentUserId;
           try {
            Map<String, dynamic> decoded = JwtDecoder.decode(token);
            currentUserId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
            } catch (e) {
            print('⚠️ Could not decode token: $e');
            }

          if (!isGroupChat && users.length == 2 && currentUserId != null) {
            for (var user in users) {
              if (user is Map) {
                final userId = user['_id'] ?? user['id'];
                if (userId != currentUserId) {
                  chatName = user['name'] ?? chatName;
                  print('📝 Direct chat renamed to: $chatName');
                  break;
                }
              }
            }
          }

          final latestMessage = chatData['latestMessage'];
          String lastMessageText = '';
          String lastMessageTime = '';

          if (latestMessage is Map) {
            lastMessageText = latestMessage['content'] ?? '';
            final sender = latestMessage['sender'];
            if (sender is Map) {
              lastMessageText = '${sender['name'] ?? "User"}: $lastMessageText';
            }

            if (latestMessage['createdAt'] != null) {
              lastMessageTime = _formatMessageTime(latestMessage['createdAt']);
            }
          }

          print('   📌 Chat: $chatName');
          print('      ID: $chatId');
          print('      Type: ${isGroupChat ? "Group" : "1-to-1"}');

          processedChats.add({
            'id': chatId,
            'chatName': chatName,  
            'isGroupChat': isGroupChat,
            'users': users,
            'groupAdmin': chatData['groupAdmin'] ?? '',
            'latestMessage': lastMessageText,
            'latestMessageTime': lastMessageTime,
            'lastMessageSender': latestMessage?['sender']?['_id'] ?? '',
            'updatedAt': chatData['updatedAt'] ?? '',
            'createdAt': chatData['createdAt'] ?? '',
            'rawChat': chatData,
          });
        }
      }

      print('✅ ${processedChats.length} valid chats processed');

      return {
        'success': true,
        'message': 'Chats fetched successfully',
        'chats': processedChats,
        'count': processedChats.length,
      };
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Unauthorized - Token expired',
        'chats': [],
      };
    } else {
      return {
        'success': false,
        'message': 'Error: ${response.statusCode}',
        'chats': [],
      };
    }
  } catch (e) {
    print('❌ Error: $e');
    return {
      'success': false,
      'message': 'Error: $e',
      'chats': [],
    };
  }
}


  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content, required String messageId,
  }) async {
    try {
      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        print('❌ No auth token');
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      print('📤 Sending message to chat: $chatId');
      print('📝 Content: $content');

      final url = '$chatApiUrl/api/message';

      print('🔗 URL: $url');
      print('📦 Body: chatId=$chatId, content=$content');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'chatId': chatId,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        print('✅ Message sent successfully');
        print('   Message ID: ${data['_id'] ?? 'N/A'}');
        print('   Sender: ${data['sender']?['name'] ?? 'Unknown'}');
        print('   Content: ${data['content'] ?? 'N/A'}');

        return {
          'success': true,
          'message': 'Message sent successfully',
          'messageData': data,
          'messageId': data['_id'],
          'sender': data['sender'],
          'content': data['content'],
          'timestamp': data['createdAt'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Bad request - Invalid chat ID or content',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Token expired',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Chat not found',
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'messages': [],
          'chat': null,
        };
      }

      print('💬 Fetching messages for chat: $chatId');

      if (chatId.isEmpty) {
        print('❌ ERROR: chatId is empty!');
        return {
          'success': false,
          'message': 'Empty chat ID',
          'messages': [],
          'chat': null,
        };
      }

      final url = '$chatApiUrl/api/message/$chatId';

      print('🔗 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('✅ Messages fetched');

        List<dynamic> messages = [];
        Map<String, dynamic>? chatInfo;

        if (data is List) {
          messages = data;
          print('✅ Got ${messages.length} messages (response is List)');
        } else if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          if (map['messages'] is List) {
            messages = map['messages'];
            print('✅ Got ${messages.length} messages from "messages" field');
          } else if (map['data'] is List) {
            messages = map['data'];
            print('✅ Got ${messages.length} messages from "data" field');
          }
          chatInfo = map;
        }

        return {
          'success': true,
          'messages': messages,
          'chat': chatInfo,
          'count': messages.length,
        };
      } else if (response.statusCode == 401) {
        print('❌ 401: Unauthorized');
        return {
          'success': false,
          'message': 'Unauthorized - Token expired',
          'messages': [],
          'chat': null,
        };
      } else if (response.statusCode == 404) {
        print('❌ 404: Messages endpoint not found');
        return {
          'success': false,
          'message': 'Messages endpoint not found',
          'messages': [],
          'chat': null,
        };
      } else {
        print('❌ Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
          'messages': [],
          'chat': null,
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'messages': [],
        'chat': null,
      };
    }
  }

  static Future<Map<String, dynamic>> renameGroupChat({
    required String groupId,
    required String newName,
  }) async {
    try {
      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        print('❌ No auth token');
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      print('✏️ Renaming group: $groupId to $newName');

      final response = await http.put(
        Uri.parse('$chatApiUrl/api/chat/group/rename'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'chatId': groupId,
          'chatName': newName,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Group renamed successfully');
        return {
          'success': true,
          'message': 'Group renamed successfully',
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized - Only group admin can rename',
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

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
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

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
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('🗑️ Removing user: $userId from group: $groupId');

      final response = await http.put(
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

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        print('✅ User removed successfully');
        return {'success': true, 'message': 'User removed'};
      }

      print('❌ Error: ${response.statusCode}');
      return {'success': false, 'message': 'Failed to remove user'};
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

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

  static Future<Map<String, dynamic>> getGroupMembers(String groupId) async {
    try {
      print('👥 Fetching group members...');
      print('   Group ID: $groupId');

      final token = PostService.authToken;
      if (token == null) {
        print('❌ No token');
        return {
          'success': false,
          'message': 'Not authenticated',
          'members': [],
        };
      }

      final response = await http.get(
        Uri.parse('$chatApiUrl/api/chat/members/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API Response received');

        if (data is Map) {
          final map = Map<String, dynamic>.from(data);

          List<dynamic> members = [];
          if (map['members'] is List) {
            members = map['members'];
          } else if (map['users'] is List) {
            members = map['users'];
          } else if (map['data'] is List) {
            members = map['data'];
          }

          print('✅ ${members.length} members fetched');

          return {
            'success': true,
            'chatName': map['chatName'] ?? map['name'] ?? 'Group',
            'members': members,
            'groupAdmin': map['groupAdmin'] ?? map['admin'] ?? '',
          };
        }

        print('⚠️ Unexpected response format');
        return {
          'success': false,
          'message': 'Unexpected response format',
          'members': [],
        };
      } else {
        print('❌ Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Error ${response.statusCode}',
          'members': [],
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'members': [],
      };
    }
  }

  static String _formatMessageTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
