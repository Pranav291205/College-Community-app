import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chatbot_provider.dart';

class ChatBotPage extends ConsumerStatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends ConsumerState<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    ref.read(chatLoadingProvider.notifier).state = true;
    await ref.read(chatProvider.notifier).sendMessage(message);
    ref.read(chatLoadingProvider.notifier).state = false;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width * 0.92,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,

                /// APP BAR
                appBar: AppBar(
              title: ShaderMask(
  shaderCallback: (bounds) => const LinearGradient(
    colors: [Color.fromARGB(255, 232, 215, 120), Color.fromARGB(255, 198, 213, 240)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(bounds),
  child: const Text(
    "! Hello 👋🏻👋🏻!",
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),


                  backgroundColor: Colors.white.withOpacity(0.15),
                  elevation: 0,
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.read(chatProvider.notifier).clearChat(),
                      tooltip: 'Clear Chat',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                /// BODY
                body: Column(
                  children: [
                   Expanded(
  child: messages.isEmpty
      ? const Center(child: Text('No messages yet', style: TextStyle(color: Colors.white70)))
      : Stack(
          children: [
            ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
              child: Scrollbar(
                controller: _scrollController,
                thickness: 4,
                radius: const Radius.circular(8),
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: messages[index]);
                    },
                  ),
                ),
              ),
            ),

            // ⬇️ Snap to bottom button
            Positioned(
              right: 14,
              bottom: 14,
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black.withOpacity(0.25),
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
),


                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text('Thinking...', style: TextStyle(color: Colors.white70))
                          ],
                        ),
                      ),

                    /// INPUT FIELD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: const TextStyle(color: Colors.white60),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                                enabled: !isLoading,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: isLoading ? Colors.white24 : Colors.blueAccent,
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                                onPressed: isLoading ? null : _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blueAccent.withOpacity(0.85)
              : message.isError
                  ? Colors.red.withOpacity(0.3)
                  : Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser ? Colors.white60 : Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
