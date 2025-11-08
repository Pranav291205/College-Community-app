import 'package:community_app/screens/create_group_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import 'group_members_screen.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with TickerProviderStateMixin {
  late AnimationController bgController;
  late Animation<double> bgAnimation;

  final _renameController = TextEditingController();
  bool _isRenaming = false;

  @override
  void initState() {
    super.initState();
    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    bgAnimation = Tween<double>(begin: 0.2, end: 0.9).animate(bgController);
  }

  @override
  void dispose() {
    bgController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  // ✅ RENAME GROUP DIALOG
  void _showRenameDialog(String groupId, String currentName) {
    _renameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162447),
        title: const Text(
          'Rename Group',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: _renameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new group name',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _renameController.text.trim();

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Group name cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newName == currentName) {
                Navigator.pop(context);
                return;
              }

              setState(() => _isRenaming = true);

              try {
                final result = await ChatService.renameGroupChat(
                  groupId: groupId,
                  newName: newName,
                );

                if (mounted) {
                  if (result['success']) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Group renamed successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    // Refresh chats
                    ref.refresh(chatGroupsProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ ${result['message']}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              if (mounted) {
                setState(() => _isRenaming = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
            ),
            child: _isRenaming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveGroup(String groupId, String groupName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162447),
        title: const Text(
          'Leave Group?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Leave "$groupName"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ChatService.leaveGroup(groupId);
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Left group'),
            backgroundColor: Colors.green,
          ),
        );
        ref.refresh(chatGroupsProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined,
                            size: 64, color: Colors.white30),
                        const SizedBox(height: 16),
                        const Text(
                          "No chats yet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateGroupChatPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Group'),
                        ),
                      ],
                    ),
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
                    final memberCount = group.users.length;

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
                                color: Colors.blue.shade200
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Card(
                            elevation: 6,
                            color: Colors.blue.shade800
                                .withOpacity(0.85),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatDetailPage(groupId: group.id, chatId: '', chatName: '',),
                                  ),
                                );
                              },
                              // ✅ LONG PRESS WITH RENAME & LEAVE OPTIONS
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    color: Colors.grey[900],
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // ✅ RENAME GROUP OPTION
                                        ListTile(
                                          leading: Icon(
                                            Icons.edit,
                                            color: Colors.blue[400],
                                            size: 24,
                                          ),
                                          title: const Text(
                                            'Rename Group',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showRenameDialog(
                                              group.id,
                                              group.chatName,
                                            );
                                          },
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                        // ✅ VIEW MEMBERS OPTION
                                        ListTile(
                                          leading: Icon(Icons.people,
                                              color: Colors.blue),
                                          title: const Text(
                                            'View Members',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    GroupMembersScreen(
                                                  groupId: group.id,
                                                  groupName: group.chatName,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                        // ✅ LEAVE GROUP OPTION
                                        ListTile(
                                          leading: Icon(Icons.exit_to_app,
                                              color: Colors.red),
                                          title: const Text(
                                            'Leave Group',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _leaveGroup(group.id,
                                                group.chatName);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.lightBlueAccent,
                                child: Text(
                                  group.chatName.isNotEmpty
                                      ? group.chatName[0]
                                          .toUpperCase()
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
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
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '👥 $memberCount members',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
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
                    ));
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      "Failed to load chats",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.refresh(chatGroupsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
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
      double fluctuation = (animationValue * 20) *
          (bubblePositions.indexOf(pos) % 2 == 0 ? 1 : -1);

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
