import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';

class GroupMembersScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMembersScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  late Future<Map<String, dynamic>> _membersFuture;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _membersFuture = ChatService.getGroupMembers(widget.groupId);
  }

  // ✅ Remove user from group
  Future<void> _removeUserFromGroup(String userId, String userName) async {
    // ✅ Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF162447),
          title: const Text(
            'Remove Member?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to remove $userName from the group?',
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
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isRemoving = true);

    try {
      print('🗑️ Removing user: $userId from group: ${widget.groupId}');

      final result = await ChatService.removeUserFromGroup(
        groupId: widget.groupId,
        userId: userId,
      );

      if (result['success']) {
        print('✅ User removed successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $userName removed from group'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // ✅ Refresh the members list
        setState(() {
          _membersFuture = ChatService.getGroupMembers(widget.groupId);
        });
      } else {
        print('❌ Failed to remove user: ${result['message']}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message'] ?? "Failed to remove user"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Exception: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isRemoving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1931),
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: const Color(0xFF0A1931),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          // ✅ Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading members...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // ✅ Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _membersFuture =
                            ChatService.getGroupMembers(widget.groupId);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ✅ Success state
          if (snapshot.hasData) {
            final groupData = snapshot.data!;
            final success = groupData['success'] ?? false;

            if (!success) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 64, color: Colors.orange[400]),
                    const SizedBox(height: 16),
                    Text(
                      groupData['message'] ?? 'Failed to load members',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _membersFuture =
                              ChatService.getGroupMembers(widget.groupId);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final members = groupData['members'] ?? [];
            final groupAdmin = groupData['groupAdmin'] ?? '';
            final chatName = groupData['chatName'] ?? widget.groupName;

            print('✅ Rendering ${members.length} members');

            if (members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64, color: Colors.blue[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'No members in this group',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // ✅ Get admin name for info box
            String adminName = 'Unknown';
            for (var member in members) {
              if (member is Map) {
                final memberId = member['_id'] ?? member['id'] ?? '';
                if (memberId == groupAdmin) {
                  adminName = member['name'] ??
                      member['userName'] ??
                      member['fullName'] ??
                      'Unknown';
                  break;
                }
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Group Info Card
                  Card(
                    elevation: 4,
                    color: const Color(0xFF162447),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.people,
                                  color: Colors.lightBlueAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${members.length} Members',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Members Header
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Members List with Remove Button
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      // ✅ Handle different member object formats
                      final memberId = member is Map
                          ? (member['_id'] ?? member['id'] ?? '')
                          : '';
                      final memberName = member is Map
                          ? (member['name'] ??
                              member['userName'] ??
                              member['fullName'] ??
                              'Unknown')
                          : 'Unknown';
                      final memberEmail = member is Map
                          ? (member['email'] ?? 'N/A')
                          : 'N/A';
                      final isAdmin = memberId == groupAdmin;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFF162447),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isAdmin
                                ? Colors.lightBlueAccent
                                : Colors.blue.shade700,
                            width: isAdmin ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isAdmin
                                ? Colors.lightBlueAccent
                                : Colors.blue.shade900,
                            radius: 24,
                            child: Text(
                              memberName.isNotEmpty
                                  ? memberName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  memberName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A1931),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              memberEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: _isRemoving ? Colors.grey : Colors.red[400],
                              size: 20,
                            ),
                            onPressed: _isRemoving
                                ? null
                                : () => _removeUserFromGroup(memberId, memberName),
                            tooltip: 'Remove member',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ✅ Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162447),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.lightBlueAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info,
                            color: Colors.lightBlueAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Group Admin: $adminName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          // ✅ No data state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, size: 64, color: Colors.blue[300]),
                const SizedBox(height: 16),
                const Text(
                  'No data available',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
