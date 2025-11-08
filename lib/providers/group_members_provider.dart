import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';

final groupMembersProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, groupId) async {
    print('📥 Provider: Fetching group members for: $groupId');
    return await ChatService.getGroupMembers(groupId);
  },
);
