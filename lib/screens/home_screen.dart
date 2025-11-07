import 'package:community_app/providers/posts_provider.dart';
import 'package:community_app/screens/chatbot.dart';
import 'package:community_app/services/comment_service.dart';
import 'package:community_app/services/like_service.dart';
import 'package:community_app/services/dislike_service.dart';
import 'package:community_app/services/post_service.dart';
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
        title: ShaderMask(
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
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
                              Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
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
                  itemBuilder: (context, index) => PostCard(post: posts[index]),
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
    );
  }
}

class _BoldRefreshIcon extends StatefulWidget {
  const _BoldRefreshIcon({Key? key}) : super(key: key);

  @override
  State<_BoldRefreshIcon> createState() => _BoldRefreshIconState();
}

class _BoldRefreshIconState extends State<_BoldRefreshIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
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
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 3))],
        ),
        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final dynamic post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final _commentController = TextEditingController();
  bool _isCommenting = false;
  List<dynamic> _comments = [];
  bool _showComments = false;
  bool _loadingComments = false;
  
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLiking = false;

  bool _isDisliked = false;
  int _dislikeCount = 0;
  bool _isDisliking = false;

  @override
  void initState() {
    super.initState();
    print('\n🆕 PostCard initState - Post ID: ${widget.post['_id']}');
    _initializePost();
  }

  // ✅ Get current user ID from JWT token
  String? _getCurrentUserId() {
    try {
      final token = PostService.authToken;
      if (token == null) {
        print('⚠️ No auth token');
        return null;
      }

      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        final userId = decoded['userId'] ?? decoded['id'] ?? decoded['_id'];
        print('👤 Extracted user ID: $userId');
        return userId;
      } catch (e) {
        print('❌ Could not decode token: $e');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  // ✅ Helper method to get first character safely
  String _getInitial(String name) {
    if (name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  // ✅ Initialize post with likes/dislikes
  void _initializePost() {
    try {
      print('🔍 Initializing post: ${widget.post['_id']}');
      print('📊 Post keys: ${widget.post.keys.toList()}');

      String? currentUserId = _getCurrentUserId();
      print('👤 Current user ID: $currentUserId');

      // ===== LIKES =====
      final likes = widget.post['likes'];
      print('❤️ Likes data: $likes (type: ${likes.runtimeType})');

      if (likes is int) {
        _likeCount = likes;
        _isLiked = false;
      } else if (likes is List) {
        _likeCount = likes.length;
        
        if (currentUserId != null && currentUserId.isNotEmpty) {
          _isLiked = likes.any((like) {
            if (like is String) return like == currentUserId;
            if (like is Map) return (like['_id'] ?? like['userId'] ?? like['id']) == currentUserId;
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
        
        if (currentUserId != null && currentUserId.isNotEmpty) {
          _isDisliked = dislikes.any((dislike) {
            if (dislike is String) return dislike == currentUserId;
            if (dislike is Map) return (dislike['_id'] ?? dislike['userId'] ?? dislike['id']) == currentUserId;
            return false;
          });
          print('👎 User disliked this post: $_isDisliked (count: $_dislikeCount)');
        }
      } else {
        _dislikeCount = 0;
        _isDisliked = false;
      }

      print('✅ Final state - Liked: $_isLiked ($_likeCount), Disliked: $_isDisliked ($_dislikeCount)\n');

      if (widget.post['mediaType'] == 'video' && widget.post['mediaUrl'] != null) {
        _initializeVideo();
      }
    } catch (e) {
      print('❌ Error initializing post: $e');
      _likeCount = 0;
      _dislikeCount = 0;
      _isLiked = false;
      _isDisliked = false;
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

  Future<void> _loadComments() async {
    if (_loadingComments) return;
    setState(() => _loadingComments = true);
    try {
      List<dynamic> comments = await CommentService.getPostComments(widget.post['_id']);
      if (comments.isEmpty) {
        comments = await CommentService.getAllCommentsForPost(widget.post['_id']);
      }
      if (mounted) setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (e) {
      print('❌ Error loading comments: $e');
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isCommenting = true);
    try {
      final result = await CommentService.addComment(
        postId: widget.post['_id'],
        text: _commentController.text.trim(),
      );
      setState(() => _isCommenting = false);
      if (result['success']) {
        _commentController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Comment added!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
          );
        }
        await _loadComments();
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isCommenting = false);
    }
  }

  // ✅ Toggle Like
  Future<void> _toggleLike() async {
    if (_isLiking || _isDisliking) return;
    setState(() => _isLiking = true);
    try {
      if (_isDisliked) {
        await DislikeService.dislikePost(widget.post['_id']);
        if (mounted) setState(() {
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

  // ✅ Toggle Dislike
  Future<void> _toggleDislike() async {
    if (_isDisliking || _isLiking) return;
    setState(() => _isDisliking = true);
    try {
      if (_isLiked) {
        await LikeService.unlikePost(widget.post['_id']);
        if (mounted) setState(() {
          _isLiked = false;
          _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
        });
      }

      final result = await DislikeService.dislikePost(widget.post['_id']);

      if (result['success'] && mounted) {
        setState(() {
          _isDisliked = !_isDisliked;
          if (result['dislikes'] is int) _dislikeCount = result['dislikes'];
          else _dislikeCount = _isDisliked ? _dislikeCount + 1 : (_dislikeCount > 0 ? _dislikeCount - 1 : 0);
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

  @override
  void dispose() {
    _commentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      // ✅ Better author name handling
      final userName = widget.post['authorName'] ?? widget.post['author'] ?? 'Anonymous User';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Post Header with proper author name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      _getInitial(userName),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Anonymous User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTimestamp(widget.post['createdAt']),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
            ),

            // Media
            if (widget.post['mediaUrl'] != null && widget.post['mediaType'] == 'image')
              Image.network(
                widget.post['mediaUrl'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text('Image failed to load', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              )
            else if (widget.post['mediaType'] == 'video' && _isVideoInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(alignment: Alignment.center, children: [
                  VideoPlayer(_videoController!),
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() =>
                      _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play()),
                  ),
                ]),
              )
            else if (widget.post['mediaType'] == 'video')
              Container(height: 250, color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator())),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (_isLiking || _isDisliking) ? null : _toggleLike,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey, size: 22),
                        const SizedBox(width: 8),
                        Text(_likeCount.toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: _isLiked ? Colors.red : Colors.grey[700])),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showComments = !_showComments);
                        if (_showComments && _comments.isEmpty) _loadComments();
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_showComments ? Icons.comment : Icons.comment_outlined,
                          color: Colors.grey[700], size: 22),
                        const SizedBox(width: 8),
                        Text('${_comments.length}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (_isDisliking || _isLiking) ? null : _toggleDislike,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: _isDisliked ? Colors.orange : Colors.grey[700], size: 22),
                        const SizedBox(width: 8),
                        Text(_dislikeCount.toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: _isDisliked ? Colors.orange : Colors.grey[700])),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(widget.post['description'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
              ]),
            ),

            // Comments
            if (_showComments) ...[
              const Divider(height: 1),
              if (_loadingComments)
                Padding(padding: const EdgeInsets.all(16),
                  child: Center(child: SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))))
              else if (_comments.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (_, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: Text((comment['userName'] ?? 'A')[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comment['userName'] ?? 'Anonymous',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(comment['text'] ?? '', style: const TextStyle(fontSize: 13),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                      Text(_formatTimestamp(comment['createdAt']),
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('No comments', style: TextStyle(color: Colors.grey[600]))),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        enabled: !_isCommenting,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isCommenting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _addComment),
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

class _MovableChatBotButtonState extends State<MovableChatBotButton> with SingleTickerProviderStateMixin {
  double x = 20;
  double y = 500;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
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
            x = (x + details.delta.dx).clamp(0.0, screenSize.width - buttonSize);
            y = (y + details.delta.dy).clamp(0.0, screenSize.height - buttonSize - 80);
          });
        },
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotPage()));
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(2, 3))],
          ),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
