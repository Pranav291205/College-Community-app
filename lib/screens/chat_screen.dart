import 'package:community_app/screens/create_group_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with TickerProviderStateMixin {
  late AnimationController bgController;
  late Animation<double> bgAnimation;

  @override
  void initState() {
    super.initState();
    bgController =
        bgController = AnimationController(
    vsync: this, duration: const Duration(seconds: 3)) // now faster
  ..repeat(reverse: true);

    bgAnimation = Tween<double>(begin: 0.2, end: 0.9).animate(bgController);
  }

  @override
  void dispose() {
    bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatGroupsAsync = ref.watch(chatGroupsProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1A237E), Color(0xff3949AB), Color(0xff5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Messages",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, size: 28),
                tooltip: 'Create Group',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateGroupChatPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // ✅ Updated Dark Blue Bubble Background
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff0A1128),
                      Color(0xff001F54),
                      Color(0xff034078),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: bgController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BubblePainter(bgAnimation.value),
                    );
                  },
                ),
              ),
            ],
          ),

          RefreshIndicator(
            onRefresh: () async => ref.refresh(chatGroupsProvider),
            child: chatGroupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(
                    child: Text("No chats yet",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final lastMessage = group.messages.isNotEmpty
                        ? group.messages.last.content
                        : 'No messages yet';
                    final lastSender = group.messages.isNotEmpty
                        ? group.messages.last.senderName
                        : '';
                    final timeAgo = _formatTime(group.updatedAt);

                    final anim = CurvedAnimation(
                      parent: const AlwaysStoppedAnimation(1),
                      curve: Curves.easeOut,
                    );

                    return FadeTransition(
                      opacity: anim,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - anim.value)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Card(
                            elevation: 6,
                            color: Colors.blue.shade800.withOpacity(0.85),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatDetailPage(groupId: group.id),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.lightBlueAccent,
                                child: Text(
                                  group.chatName.isNotEmpty
                                      ? group.chatName[0].toUpperCase()
                                      : 'G',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                group.chatName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lastSender.isNotEmpty
                                      ? "$lastSender: $lastMessage"
                                      : lastMessage,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    timeAgo,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (group.messages.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.lightBlueAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text(
                                        "1",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, _) => const Center(
                child: Text(
                  "Failed to load chats",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final date = DateTime.parse(dateString);
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return "${date.day}/${date.month}/${date.year}";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "now";
  } catch (_) {
    return '';
  }
}

// ✅ Bubble Animation Painter
class BubblePainter extends CustomPainter {
  final double animationValue;
  BubblePainter(this.animationValue);

  final List<Offset> bubblePositions = [
    Offset(0.2, 0.8),
    Offset(0.5, 0.6),
    Offset(0.8, 0.9),
    Offset(0.3, 0.4),
    Offset(0.7, 0.3),
    Offset(0.1, 0.6),
    Offset(0.9, 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    for (var pos in bubblePositions) {
      double fluctuation =
          (animationValue * 20) * (bubblePositions.indexOf(pos) % 2 == 0 ? 1 : -1);

      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height + fluctuation),
        28 + (animationValue * 12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
