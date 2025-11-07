import 'package:community_app/providers/chat_provider.dart';
import 'package:community_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupChatPage extends ConsumerStatefulWidget {
  const CreateGroupChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupChatPage> createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends ConsumerState<CreateGroupChatPage> {
  final _groupNameController = TextEditingController();
  final Set<String> _selectedUserIds = {}; 
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = false;
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    setState(() => _isLoadingUsers = true);

    setState(() {
      _availableUsers = [
        {
          '_id': '69073a60f4793a13be5ae0f3', 
          'name': 'Kartikey Mishra',
          'email': 'kartikey@akgec.ac.in',
          'branch': 'CSE',
          'year': '2nd',
        },
        {
          '_id': '690a6d2cfe96729570e3908d',
          'name': 'Pranav Rastogi',
          'email': 'pranav12@akgec.ac.in',
          'branch': 'CSE(DS)',
          'year': '2nd',
        },
        {
          '_id': '690a6d2cfe96729570e3908e',
          'name': 'John Doe',
          'email': 'john@example.com',
          'branch': 'CSE',
          'year': '3rd',
        },
        {
          '_id': '690a6d2cfe96729570e3908f',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'branch': 'ECE',
          'year': '2nd',
        },
        {
          '_id': '690a6d2cfe96729570e39090',
          'name': 'Alex Johnson',
          'email': 'alex@example.com',
          'branch': 'IT',
          'year': '1st',
        },
      ];
      _isLoadingUsers = false;
    });
  }

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
    
    print('📤 Creating group with:');
    print('   Name: ${_groupNameController.text}');
    print('   Users: $usersList');
    print('   User count: ${usersList.length}');

    final result = await ChatService.createGroup(
      chatName: _groupNameController.text,
      users: usersList,  
    );

    setState(() => _isLoading = false);

    print('📊 Result: $result');

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
  return Scaffold(
    backgroundColor: const Color(0xFF0A1931), // Dark Blue BG

    appBar: AppBar(
      title: const Text('Create Group Chat'),
      backgroundColor: const Color(0xFF0A1931),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    body: _isLoadingUsers
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ✅ GROUP NAME CARD
                Card(
                  elevation: 4,
                  color: const Color(0xFF162447), // Highlighted box
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                            hintStyle: TextStyle(color: Colors.white60),
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
                            fillColor: const Color(0xFF1A2B3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ SELECT USERS HEADER
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
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.lightBlueAccent),
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

                // ✅ LIST OF USERS
                if (_availableUsers.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.person_off,
                              size: 64, color: Colors.blue.shade200),
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
                    itemCount: _availableUsers.length,
                    itemBuilder: (context, index) {
                      final user = _availableUsers[index];
                      final userId = user['_id'];
                      final isSelected = _selectedUserIds.contains(userId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFF162447), // Highlight blue box
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.lightBlueAccent
                                : Colors.blue.shade700,
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
                                : Colors.blue.shade900,
                            child: Text(
                              user['name'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                user['email'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user['branch']} - ${user['year']} Year',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
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

                // ✅ CREATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
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
                              color: Color(0xFF0A1931),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ INFO BOX
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162447),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.lightBlueAccent),
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
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
  );
}

}
