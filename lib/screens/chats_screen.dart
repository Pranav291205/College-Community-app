import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ✅ LOAD CHATS FROM API
  Future<void> _loadChats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📥 Loading chats...');

      final result = await ChatService.fetchChats();

      if (!mounted) return;

      print('📊 fetchChats result:');
      print('   Success: ${result['success']}');
      print('   Count: ${result['count']}');
      print('   Message: ${result['message']}');

      if (result['success']) {
        final chats = result['chats'] ?? [];

        setState(() {
          _chats = chats;
          _isLoading = false;
        });

        print('✅ Loaded ${_chats.length} chats');
        for (var i = 0; i < _chats.length; i++) {
          final chat = _chats[i];
          print('   [$i] ${chat['chatName']} (${chat['id']})');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              result['message'] ?? 'Failed to load chats';
        });
        print('❌ Error: ${result['message']}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // ✅ OPEN CHAT DETAIL
  void _openChat(dynamic chat) {
    final chatId = chat['id']; // ✅ GET chatId
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
          chatId: chatId, // ✅ PASS chatId
          chatName: chatName, groupId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadChats,
            tooltip: 'Refresh chats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : _errorMessage != null
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
                          _errorMessage ?? 'Unknown error',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadChats,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : _chats.isEmpty
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
                            onPressed: _loadChats,
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
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        final chat = _chats[index];

                        if (chat is! Map) {
                          return const SizedBox.shrink();
                        }

                        final chatId = chat['id']; // ✅ GET chatId
                        final chatName = chat['chatName'] ?? 'Chat';
                        final isGroupChat = chat['isGroupChat'] ?? false;
                        final userCount = chat['users']?.length ?? 0;
                        final latestMessage =
                            chat['latestMessage'] ?? '';

                        print(
                            '📌 Chat $index: $chatName (ID: $chatId)');

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
                                isGroupChat
                                    ? Icons.group
                                    : Icons.person,
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                    padding:
                                        const EdgeInsets.only(top: 4),
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
                            onTap: () => _openChat(chat), // ✅ PASS chat
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadChats,
        backgroundColor: Colors.blue.shade600,
        tooltip: 'Refresh chats',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
