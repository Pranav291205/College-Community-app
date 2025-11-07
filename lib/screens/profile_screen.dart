import 'package:community_app/providers/liked_posts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/post_service.dart';
import '../providers/auth_notifier.dart';
import '../providers/posts_provider.dart';
import '../providers/commented_posts_provider.dart';
import '../auth/login_page.dart';
import 'home_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = PostService.authToken;

      if (token == null || token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://college-community-app-backend.onrender.com/api/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic>? userData = data['data'] ?? data['user'] ?? data;

        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);
    final userPostsAsync = ref.watch(userPostsProvider);
    final commentedPostsAsync = ref.watch(commentedPostsProvider);
    final likedPostsAsync = ref.watch(likedPostsProvider);

    if (token == null || token.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Please login to view profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load profile'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final name = _userData?['name'] ?? 'User';
    final email = _userData?['email'] ?? 'user@example.com';
    final branch = _userData?['branch'] ?? 'N/A';
    final year = _userData?['year'] ?? 'N/A';
    final userId = _userData?['_id'] ?? 'N/A';
    final createdAt = _userData?['createdAt'] ?? '';
    final interests = (_userData?['interests'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 208, 229, 245),
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadUserProfile();
            ref.refresh(userPostsProvider);
            ref.refresh(commentedPostsProvider);
            ref.refresh(likedPostsProvider);
          },
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: const Color.fromARGB(255, 164, 212, 225)
                          .withOpacity(0.9),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _showImagePickerOptions,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.blue.shade100,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                    child: _profileImage == null
                                        ? Text(
                                            name[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue[800],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.camera_alt,
                                          size: 20, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          branch,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$year Year',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.purple.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            Row(
                              children: [
                                Icon(Icons.fingerprint,
                                    color: Colors.purple.shade600, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User ID',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        userId,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy,
                                      color: Colors.purple.shade700, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: userId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✅ User ID copied!'),
                                        duration: Duration(seconds: 1),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.purple.shade600, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Account Created',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatCreatedDate(createdAt),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.purple.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (interests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Interests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: interests
                                .map(
                                  (interest) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Text(
                                      interest,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 2),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Posts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            userPostsAsync.when(
                              data: (posts) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${posts.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        userPostsAsync.when(
                          data: (posts) {
                            if (posts.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.post_add,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) =>
                                  PostCard(post: posts[index]),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text('Error: $error'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 2),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.comment,
                                    color: Colors.orange.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Commented Posts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            commentedPostsAsync.when(
                              data: (posts) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${posts.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        commentedPostsAsync.when(
                          data: (posts) {
                            if (posts.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.comment_outlined,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No commented posts yet',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) =>
                                  PostCard(post: posts[index]),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text('Error: $error'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 2),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Liked Posts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            likedPostsAsync.when(
                              data: (posts) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${posts.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        likedPostsAsync.when(
                          data: (posts) {
                            if (posts.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.favorite_outline,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No liked posts yet',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) =>
                                  PostCard(post: posts[index]),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text('Error: $error'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCreatedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago (${_formatDate(dateString)})';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago (${_formatDate(dateString)})';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago (${_formatDate(dateString)})';
      } else {
        return 'Today (${_formatDate(dateString)})';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() => _profileImage = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authTokenProvider.notifier).clearToken();
                PostService.clearAuthToken();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
