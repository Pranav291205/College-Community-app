import 'package:community_app/models/search_posts_modal.dart';
import 'package:community_app/providers/posts_provider.dart';
import 'package:community_app/screens/chatbot.dart';
import 'package:community_app/services/comment_service.dart';
import 'package:community_app/services/like_service.dart';
import 'package:community_app/services/dislike_service.dart';
import 'package:community_app/services/post_service.dart';
import 'package:community_app/widgets/search_users_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        toolbarHeight: 75,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'CollabSpace',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              "assets/images/logo.png",
              height: 45,
              width: 45,
              fit: BoxFit.contain,
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A1F44),
                Color(0xFF1B3A73),
              ], // ✅ Dark Blue Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'search_users') {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const SearchUsersModal(),
                );
              } else if (value == 'search_posts') {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const SearchPostsModal(),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'search_users',
                child: Row(
                  children: [
                    Icon(Icons.person_search),
                    SizedBox(width: 8),
                    Text('Search Users'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search_posts',
                child: Row(
                  children: [
                    Icon(Icons.article_outlined),
                    SizedBox(width: 8),
                    Text('Search Posts'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.only(top: 5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 123, 209, 255),
              Color.fromARGB(255, 215, 229, 241),
            ], // ✅ Background gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(postsProvider);
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.post_add,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) => PostCard(
                      post: posts[index],
                      onPostDeleted: () => ref.refresh(postsProvider),
                    ),
                  );
                },
                loading: () => const Center(child: _BoldRefreshIcon()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text('Error: $err'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(postsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const MovableChatBotButton(),
          ],
        ),
      ),
    );
  }

  void _showSearchUsersModal(BuildContext context) {
    final searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchUsersModal(),
    );
  }

  void _showSearchPostsModal(BuildContext context) {
    final searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchPostsModal(),
    );
  }
}

class _BoldRefreshIcon extends StatefulWidget {
  const _BoldRefreshIcon({Key? key}) : super(key: key);

  @override
  State<_BoldRefreshIcon> createState() => _BoldRefreshIconState();
}

class _BoldRefreshIconState extends State<_BoldRefreshIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 37, 73, 115), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final dynamic post;
  final VoidCallback onPostDeleted;

  const PostCard({Key? key, required this.post, required this.onPostDeleted})
    : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final _commentController = TextEditingController();
  bool _isCommenting = false;
  List<dynamic> comments = [];
  int totalComments = 0;
  bool showComments = false;
  bool loadingComments = false;
  int currentPage = 1;
  int totalPages = 1;

  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  bool _isDisliked = false;
  int _dislikeCount = 0;
  bool _isDisliking = false;

  bool _isDeleting = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    print('\n🆕 PostCard initState - Post ID: ${widget.post['_id']}');
    _getCurrentUserId();

    _initializePost();
  }

  void _getCurrentUserId() {
    try {
      final token = PostService.authToken;
      print('🔐 Token: ${token != null ? "exists" : "null"}');

      if (token == null) {
        print('⚠️ No auth token');
        _currentUserId = null;
        return;
      }

      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        _currentUserId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
        print('👤 CURRENT USER ID SET: $_currentUserId');

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('❌ Could not decode token: $e');
        _currentUserId = null;
      }
    } catch (e) {
      print('❌ Error getting user ID: $e');
      _currentUserId = null;
    }
  }

  String _getInitial(String name) {
    if (name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  String _extractPostUserId() {
    try {
      if (widget.post is Map) {
        String? userId =
            widget.post['userId'] ??
            widget.post['authorId'] ??
            (widget.post['author'] is Map
                ? widget.post['author']['_id']
                : null) ??
            (widget.post['author'] is Map
                ? widget.post['author']['userId']
                : null) ??
            (widget.post['author'] is Map
                ? widget.post['author']['id']
                : null) ??
            '';

        return userId.toString().isEmpty ? '' : userId.toString();
      }
    } catch (e) {
      print('❌ Error extracting userId: $e');
    }
    return '';
  }

  void _initializePost() async {  // ✅ Made async
  try {
    print('🔍 Initializing post: ${widget.post['_id']}');
    print('📊 Post keys: ${widget.post.keys.toList()}');

    // ===== LIKES =====
    final likes = widget.post['likes'];
    print('❤️ Likes data: $likes (type: ${likes.runtimeType})');

    if (likes is int) {
      _likeCount = likes;
      _isLiked = false;
    } else if (likes is List) {
      _likeCount = likes.length;

      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        _isLiked = likes.any((like) {
          if (like is String) return like == _currentUserId;
          if (like is Map)
            return (like['_id'] ?? like['userId'] ?? like['id']) ==
                _currentUserId;
          return false;
        });
        print('❤️ User liked this post: $_isLiked (count: $_likeCount)');
      }
    } else {
      _likeCount = 0;
      _isLiked = false;
    }

    // ===== DISLIKES =====
    final dislikes = widget.post['dislikes'];
    print('👎 Dislikes data: $dislikes (type: ${dislikes.runtimeType})');

    if (dislikes is int) {
      _dislikeCount = dislikes;
      _isDisliked = false;
    } else if (dislikes is List) {
      _dislikeCount = dislikes.length;

      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        _isDisliked = dislikes.any((dislike) {
          if (dislike is String) return dislike == _currentUserId;
          if (dislike is Map)
            return (dislike['_id'] ?? dislike['userId'] ?? dislike['id']) ==
                _currentUserId;
          return false;
        });
        print(
          '👎 User disliked this post: $_isDisliked (count: $_dislikeCount)',
        );
      }
    } else {
      _dislikeCount = 0;
      _isDisliked = false;
    }

    print(
      '✅ Final state - Liked: $_isLiked ($_likeCount), Disliked: $_isDisliked ($_dislikeCount)\n',
    );

    // ===== VIDEO =====
    if (widget.post['mediaType'] == 'video' &&
        widget.post['mediaUrl'] != null) {
      _initializeVideo();
    }

    // ===== COMMENTS - Get initial comment count =====
    final commentsData = widget.post['comments'];
    if (commentsData is List) {
      totalComments = commentsData.length;
    } else if (widget.post['totalComments'] != null) {
      totalComments = widget.post['totalComments'] is int
          ? widget.post['totalComments']
          : 0;
    }
    
    print('📊 Initial total comments from post data: $totalComments');

    // ✅ NEW CODE - Fetch real comment count from API
    if (totalComments == 0) {
      try {
        final result = await PostService.getComments(
          postId: widget.post['_id'],
          page: 1,
          limit: 1,  // Only need 1 comment to get the total count
        );
        
        if (mounted && result['success']) {
          setState(() {
            totalComments = result['totalComments'] ?? 0;
          });
          print('✅ Updated total comments from API: $totalComments');
        }
      } catch (e) {
        print('⚠️ Could not fetch comment count: $e');
      }
    }
    
    print('📊 Final total comments: $totalComments');

  } catch (e) {
    print('❌ Error initializing post: $e');
    _likeCount = 0;
    _dislikeCount = 0;
    _isLiked = false;
    _isDisliked = false;
    totalComments = 0;  // ✅ Added this
  }
}


  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.post['mediaUrl']);
      await _videoController!.initialize();
      if (mounted) setState(() => _isVideoInitialized = true);
    } catch (e) {
      print('❌ Video init error: $e');
    }
  }

  Future<void> loadComments() async {
    if (loadingComments) return;

    setState(() {
      loadingComments = true;
    });

    try {
      final result = await PostService.getComments(
        postId: widget.post['_id'],
        page: currentPage,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          if (result['success']) {
            totalComments = result['totalComments'] ?? 0;
            comments = result['comments'] ?? [];
            totalPages = result['totalPages'] ?? 1;
          }
          loadingComments = false;
        });
      }
    } catch (e) {
      print('❌ Error loading comments: $e');
      if (mounted) {
        setState(() {
          loadingComments = false;
        });
      }
    }
  }

  Future<void> addComment(TextEditingController controller) async {
  if (controller.text.trim().isEmpty) return;
  
  // ✅ Prevent multiple submissions
  if (_isCommenting) {
    print('⚠️ Already submitting comment, please wait...');
    return;
  }

  setState(() {
    _isCommenting = true;
  });

  try {
    print('💬 Adding comment to post: ${widget.post['_id']}');
    
    final result = await PostService.addComment(
      postId: widget.post['_id'],
      content: controller.text.trim(),
    );

    print('📊 Comment result: $result');  // ✅ ADD DEBUG

    if (result['success']) {
      controller.clear();
      
      // ✅ Refresh comments to get updated list and count
      await loadComments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      print('❌ Failed to add comment: ${result['message']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print('❌ Error adding comment: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isCommenting = false;
      });
    }
  }
}


  Future<void> _toggleLike() async {
    if (_isLiking || _isDisliking) return;
    setState(() => _isLiking = true);
    try {
      if (_isDisliked) {
        await DislikeService.dislikePost(widget.post['_id']);
        if (mounted)
          setState(() {
            _isDisliked = false;
            _dislikeCount = _dislikeCount > 0 ? _dislikeCount - 1 : 0;
          });
      }

      final result = _isLiked
          ? await LikeService.unlikePost(widget.post['_id'])
          : await LikeService.likePost(widget.post['_id']);

      if (result['success'] && mounted) {
        setState(() {
          _isLiked = !_isLiked;
          if (result['likes'] is int) _likeCount = result['likes'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? '❤️ Liked!' : '👍 Removed'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    }
    if (mounted) setState(() => _isLiking = false);
  }

  Future<void> _toggleDislike() async {
    if (_isDisliking || _isLiking) return;
    setState(() => _isDisliking = true);
    try {
      if (_isLiked) {
        await LikeService.unlikePost(widget.post['_id']);
        if (mounted)
          setState(() {
            _isLiked = false;
            _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
          });
      }

      final result = await DislikeService.dislikePost(widget.post['_id']);

      if (result['success'] && mounted) {
        setState(() {
          _isDisliked = !_isDisliked;
          if (result['dislikes'] is int)
            _dislikeCount = result['dislikes'];
          else
            _dislikeCount = _isDisliked
                ? _dislikeCount + 1
                : (_dislikeCount > 0 ? _dislikeCount - 1 : 0);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDisliked ? '👎 Disliked!' : '✅ Removed'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    }
    if (mounted) setState(() => _isDisliking = false);
  }

  Future<void> _deletePost() async {
    final postUserId = _extractPostUserId();
    print('🔐 Current User: $_currentUserId');
    print('🔐 Post User: $postUserId');

    if (postUserId.isEmpty || postUserId != _currentUserId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ You can only delete your own posts'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162447),
        title: const Text(
          'Delete Post?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final postId = widget.post['_id'];
      print('🗑️ Deleting post: $postId');

      final result = await PostService.deletePost(postId);

      if (result['success']) {
        print('✅ Post deleted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          widget.onPostDeleted();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
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
      setState(() => _isDeleting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final userName =
          widget.post['authorName'] ??
          widget.post['author'] ??
          'Anonymous User';
      final postUserId = _extractPostUserId();
      final isOwner =
          (_currentUserId != null &&
          _currentUserId!.isNotEmpty &&
          postUserId.isNotEmpty &&
          postUserId == _currentUserId);

      print('🔍 POST OWNER CHECK:');
      print('   Current User ID: $_currentUserId');
      print('   Post User ID: $postUserId');
      print('   Is Owner: $isOwner');
      print('   Show Dots: $isOwner');

      return Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 15, 54, 125),
              Color.fromARGB(255, 133, 176, 249),
            ], // 💙 Bold blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      _getInitial(userName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Anonymous User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTimestamp(widget.post['createdAt']),
                          style: TextStyle(
                            color: const Color.fromARGB(255, 238, 235, 235),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.red[400],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Delete',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: _isDeleting ? Colors.grey : Colors.black,
                        size: 20,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            if (widget.post['mediaUrl'] != null &&
                widget.post['mediaUrl'].toString().isNotEmpty)
              if (widget.post['mediaType'] == 'image')
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: Image.network(
                    widget.post['mediaUrl'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Image load error: $error');
                      print('📥 URL: ${widget.post['mediaUrl']}');
                      return Container(
                        height: 250,
                        color: const Color.fromARGB(255, 38, 39, 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Image unavailable',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    125,
                                    130,
                                    136,
                                  ),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else if (widget.post['mediaType'] == 'video')
                if (_isVideoInitialized)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                        IconButton(
                          icon: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 64,
                            color: const Color.fromARGB(255, 50, 51, 54),
                          ),
                          onPressed: () => setState(
                            () => _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play(),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 250,
                    color: const Color.fromARGB(255, 38, 39, 40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Video unavailable',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (_isLiking || _isDisliking) ? null : _toggleLike,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked
                                ? const Color.fromARGB(255, 190, 31, 19)
                                : const Color.fromARGB(255, 232, 212, 212),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _likeCount.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isLiked
                                  ? Colors.red
                                  : const Color.fromARGB(255, 232, 212, 212),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () => showComments = !showComments,
                        ); // ✅ CORRECT
                        if (showComments && comments.isEmpty) {
                          // ✅ CORRECT
                          loadComments(); // ✅ CORRECT (no underscore)
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showComments
                                ? Icons.comment
                                : Icons.comment_outlined,
                            color: const Color.fromARGB(255, 232, 212, 212),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalComments',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 232, 212, 212),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (_isDisliking || _isLiking)
                          ? null
                          : _toggleDislike,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isDisliked
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            color: _isDisliked
                                ? Colors.orange
                                : const Color.fromARGB(255, 232, 212, 212),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dislikeCount.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isDisliked
                                  ? Colors.orange
                                  : const Color.fromARGB(255, 232, 212, 212),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.post['description'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            if (showComments) ...[
              const Divider(height: 1),

              // This shows the count
              if (totalComments > 0)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '$totalComments Comment${totalComments != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),

              if (loadingComments)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (comments.isNotEmpty) // ✅ THIS SHOULD SHOW THE COMMENTS
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      final comment = comments[index];

                      // Extract user info from API
                      final userName = comment['user'] != null
                          ? (comment['user']['name'] ?? 'Anonymous')
                          : 'Anonymous';

                      final commentText = comment['text'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        commentText,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12, color: Colors.white24),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else if (!loadingComments) // ✅ Show when no comments
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No comments yet. Be the first to comment!',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No comments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        enabled: !_isCommenting,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isCommenting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: _isCommenting
                                ? null // ✅ Disable button while submitting
                                : () async {
                                    if (_commentController.text
                                        .trim()
                                        .isEmpty) {
                                      return;
                                    }
                                    await addComment(_commentController);
                                  },
                          ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Center(child: Text('Error: $e')),
      );
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}

class MovableChatBotButton extends StatefulWidget {
  const MovableChatBotButton({Key? key}) : super(key: key);

  @override
  State<MovableChatBotButton> createState() => _MovableChatBotButtonState();
}

class _MovableChatBotButtonState extends State<MovableChatBotButton>
    with SingleTickerProviderStateMixin {
  double x = 20;
  double y = 500;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double buttonSize = 60;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            x = (x + details.delta.dx).clamp(
              0.0,
              screenSize.width - buttonSize,
            );
            y = (y + details.delta.dy).clamp(
              0.0,
              screenSize.height - buttonSize - 80,
            );
          });
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
