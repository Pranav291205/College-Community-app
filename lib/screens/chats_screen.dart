import 'package:community_app/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';

final chatsProvider = StateNotifierProvider<ChatsNotifier, ChatsState>(
  (ref) => ChatsNotifier(),
);

class ChatsState {
  final List<dynamic> chats;
  final bool isLoading;
  final String? errorMessage;

  ChatsState({
    this.chats = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  ChatsState copyWith({
    List<dynamic>? chats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ChatsNotifier extends StateNotifier<ChatsState> {
  ChatsNotifier() : super(ChatsState()) {
    loadChats();
  }

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('📥 Loading chats...');

      final result = await ChatService.fetchChats();

      print('📊 fetchChats result:');
      print('   Success: ${result['success']}');
      print('   Count: ${result['count']}');
      print('   Message: ${result['message']}');

      if (result['success']) {
        final chats = result['chats'] ?? [];

        state = state.copyWith(
          chats: chats,
          isLoading: false,
          errorMessage: null,
        );

        print('✅ Loaded ${state.chats.length} chats');
        for (var i = 0; i < state.chats.length; i++) {
          final chat = state.chats[i];
          print('   [$i] ${chat['chatName']} (${chat['id']})');
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Failed to load chats',
          chats: [],
        );
        print('❌ Error: ${result['message']}');
      }
    } catch (e) {
      print('❌ Exception: $e');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: $e',
        chats: [],
      );
    }
  }
}

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  void _openChat(BuildContext context, dynamic chat) {
    final chatId = chat['id']; 
    final chatName = chat['chatName'];

    print('🔗 Opening chat:');
    print('   Name: $chatName');
    print('   ID: $chatId');

    if (chatId == null || chatId.isEmpty) {
      print('❌ ERROR: chatId is null or empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid chat ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          chatId: chatId, 
          chatName: chatName,
          groupId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsState = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(
  elevation: 6,
  backgroundColor: Colors.blue.shade600,
  title: const Text(
    'Chats',
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () => _showUserSearchDialog(context, ref),
      tooltip: 'Search Users',
    ),
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: () => ref.read(chatsProvider.notifier).loadChats(),
      tooltip: 'Refresh chats',
    ),
  ],
),

      body: chatsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : chatsState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          chatsState.errorMessage ?? 'Unknown error',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(chatsProvider.notifier).loadChats(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : chatsState.chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chats yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ref.read(chatsProvider.notifier).loadChats(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: chatsState.chats.length,
                      itemBuilder: (context, index) {
                        final chat = chatsState.chats[index];

                        if (chat is! Map) {
                          return const SizedBox.shrink();
                        }

                        final chatId = chat['id']; 
                        final chatName = chat['chatName'] ?? 'Chat';
                        final isGroupChat = chat['isGroupChat'] ?? false;
                        final userCount = chat['users']?.length ?? 0;
                        final latestMessage = chat['latestMessage'] ?? '';

                        print('📌 Chat $index: $chatName (ID: $chatId)');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: isGroupChat
                                  ? Colors.orange.shade400
                                  : Colors.blue.shade400,
                              child: Icon(
                                isGroupChat ? Icons.group : Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              chatName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (isGroupChat)
                                  Text(
                                    '$userCount members',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (latestMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      latestMessage,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                            onTap: () => _openChat(context, chat), 
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(chatsProvider.notifier).loadChats(),
        backgroundColor: Colors.blue.shade600,
        tooltip: 'Refresh chats',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
    
  }
void _showUserSearchDialog(BuildContext context, WidgetRef ref) {
  final searchController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Search Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final query = searchController.text.trim();
                  
                  if (query.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a search term'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final result = await SearchService.searchUsers(query);
                  final users = result['users'] ?? [];

                  if (context.mounted) {
                    Navigator.pop(context); 

                    if (users.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No users found'),
                        ),
                      );
                      return;
                    }

                    _showUserSelectionDialog(context, ref, users);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Text('Search'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ),
  );
}

void _showUserSelectionDialog(
  BuildContext context,
  WidgetRef ref,
  List<dynamic> users,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Select User'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade400,
                child: Text(
                  (user['name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user['name'] ?? 'Unknown'),
              subtitle: Text(user['email'] ?? ''),
              onTap: () async {
  final otherUserId = user['_id'] ?? 
                     user['id'] ?? 
                     user['user_id'] ?? 
                     '';
  final otherUserName = user['name'] ?? 'User';

  print('🔍 Selected user:');
  print('   User ID: $otherUserId');
  print('   User Name: $otherUserName');

  if (otherUserId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Invalid user ID'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  Navigator.pop(dialogContext);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
                final result = await ChatService.getOrCreateDirectChat(
                  otherUserId,
                );

                if (context.mounted) {
                  Navigator.pop(context);

                  if (result['success']) {
                    final chat = result['chat'];
                    final chatId = chat['_id'] ?? chat['id'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          chatId: chatId,
                          chatName: otherUserName,
                          groupId: '',
                        ),
                      ),
                    );

                    ref.read(chatsProvider.notifier).loadChats();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ ${result['message']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

}
