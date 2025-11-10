import 'dart:ui';
import 'package:community_app/providers/chat_provider.dart';
import 'package:community_app/providers/users_provider.dart';
import 'package:community_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupChatDialog extends ConsumerStatefulWidget {
  const CreateGroupChatDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupChatDialog> createState() =>
      _CreateGroupChatDialogState();
}

class _CreateGroupChatDialogState extends ConsumerState<CreateGroupChatDialog> {
  final _groupNameController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  bool _isLoading = false;

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter group name'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one user'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final usersList = _selectedUserIds.toList();

    final result = await ChatService.createGroup(
      chatName: _groupNameController.text,
      users: usersList,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Group created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      ref.refresh(chatGroupsProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(recommendedUsersProvider);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300,maxHeight: 600),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // translucent glass
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.3)),
            ),
            child: usersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(recommendedUsersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (availableUsers) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group Name Input
                      Card(
                        elevation: 0,
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.lightBlueAccent.withOpacity(0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Group Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _groupNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter group name (e.g., CSE Batch 2023)',
                                  hintStyle: const TextStyle(color: Colors.white60),
                                  prefixIcon: const Icon(Icons.group, color: Colors.lightBlueAccent),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Select Users Header & list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Users',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${_selectedUserIds.length} selected',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (availableUsers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.person_off, size: 64, color: Colors.white30),
                                const SizedBox(height: 12),
                                const Text(
                                  'No users available',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: availableUsers.length,
                          itemBuilder: (context, index) {
                            final user = availableUsers[index];
                            final userId = user['_id'] ?? user['id'] ?? '';
                            final userName = user['name'] ?? user['userName'] ?? 'Unknown';
                            final userEmail = user['email'] ?? 'N/A';
                            final branch = user['branch'] ?? 'N/A';
                            final year = user['year'] ?? 'N/A';
                            final isSelected = _selectedUserIds.contains(userId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.lightBlueAccent.withOpacity(0.5)
                                      : Colors.blue.shade700.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    isSelected
                                        ? _selectedUserIds.remove(userId)
                                        : _selectedUserIds.add(userId);
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Colors.lightBlueAccent
                                      : Colors.blue.shade900.withOpacity(0.7),
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                    )),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(userEmail,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        )),
                                    const SizedBox(height: 4),
                                    Text('$branch - $year Year',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white60,
                                        )),
                                  ],
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      value == true
                                          ? _selectedUserIds.add(userId)
                                          : _selectedUserIds.remove(userId);
                                    });
                                  },
                                  activeColor: Colors.lightBlueAccent,
                                  side: const BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 32),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent.withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Create Group',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info, color: Colors.lightBlueAccent, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You will be the group admin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162447),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.lightBlueAccent),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info,
                          color: Colors.lightBlueAccent, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will be the group admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
