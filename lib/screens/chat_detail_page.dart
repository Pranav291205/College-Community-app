import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/chat_service.dart';

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
  (ref, chatId) => MessagesNotifier(chatId),
);

class MessagesState {
  final List<dynamic> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  MessagesState({
    this.messages = const [],
    this.isLoading = true,
    this.isSending = false,
    this.errorMessage,
  });

  MessagesState copyWith({
    List<dynamic>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final String chatId;

  MessagesNotifier(this.chatId) : super(MessagesState()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('💬 Fetching messages for chat: $chatId');

      final result = await ChatService.getChatMessages(chatId);

      print('📊 Result:');
      print('   Success: ${result['success']}');
      print('   Count: ${result['count']}');
      print('   Message: ${result['message']}');

      if (result['success']) {
        final messages = result['messages'] ?? [];

        state = state.copyWith(
          messages: messages,
          isLoading: false,
          errorMessage: null,
        );

        print('✅ Loaded ${state.messages.length} messages');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Failed to load messages',
          messages: [],
        );

        print('❌ Error: ${result['message']}');
      }
    } catch (e) {
      print('❌ Exception: $e');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: $e',
        messages: [],
      );
    }
  }

  Future<Map<String, dynamic>> sendMessage(String content) async {
    if (content.isEmpty) {
      return {'success': false, 'message': 'Message cannot be empty'};
    }

    state = state.copyWith(isSending: true);

    try {
      print('📤 Sending message...');

      final result = await ChatService.sendMessage(
        chatId: chatId,
        content: content,
        messageId: '',
      );

      if (result['success']) {
        print('✅ Message sent successfully');
        print('   Message ID: ${result['messageId']}');

        await loadMessages();
      } else {
        print('❌ Error: ${result['message']}');
      }

      state = state.copyWith(isSending: false);
      return result;
    } catch (e) {
      print('❌ Exception: $e');
      state = state.copyWith(isSending: false);
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

class ChatDetailPage extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.chatName,
    required String groupId,
  }) : super(key: key);

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Message cannot be empty'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final result = await ref
        .read(messagesProvider(widget.chatId).notifier)
        .sendMessage(content);

    if (!mounted) return;

    if (result['success']) {
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Message sent'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 500),
        ),
      );

      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['message']}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';

      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.blue.shade600,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[200],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref
                .read(messagesProvider(widget.chatId).notifier)
                .loadMessages(),
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: messagesState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : messagesState.errorMessage != null
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
                          messagesState.errorMessage ?? 'Unknown error',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref
                            .read(messagesProvider(widget.chatId).notifier)
                            .loadMessages(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: messagesState.messages.isEmpty
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
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start the conversation',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              itemCount: messagesState.messages.length,
                              itemBuilder: (context, index) {
                                final message = messagesState
                                    .messages[messagesState.messages.length - 1 - index];

                                if (message is! Map) {
                                  return const SizedBox.shrink();
                                }

                                final Map<String, dynamic> msg =
                                    Map<String, dynamic>.from(message);

                                final senderName =
                                    msg['sender']?['name'] ?? 'Unknown';
                                final content = msg['content'] ?? '';
                                final timestamp = msg['createdAt'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue
                                                  .withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          content,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatMessageTime(timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(24),
                                  border:
                                      Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  maxLines: null,
                                  enabled: !messagesState.isSending,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.shade600,
                              child: IconButton(
                                icon: messagesState.isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                onPressed: messagesState.isSending
                                    ? null
                                    : _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
