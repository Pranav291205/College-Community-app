import 'package:community_app/screens/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/post_provider.dart';

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
              colors: [
                Color(0xFF1565C0),
                Color(0xFF42A5F5),
              ],
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
        data: (posts) => posts.isEmpty
            ? ListView(
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
              )
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => PostCard(post: posts[index]),
              ),
        loading: () => const Center(child: _BoldRefreshIcon()),
        error: (err, __) => Center(child: Text('Error: $err')),
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

class _BoldRefreshIconState extends State<_BoldRefreshIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}


extension on AsyncValue<List> {
  // ignore: unused_element
  get future => null;
}


extension on AsyncValue<List> {
   // ignore: unused_element
   get future => null;
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

  @override
  void initState() {
    super.initState();
    if (widget.post['mediaType'] == 'video' && widget.post['mediaUrl'] != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.post['mediaUrl']);
    await _videoController!.initialize();
    setState(() => _isVideoInitialized = true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blue, child: Text(widget.post['authorName']?[0]?.toUpperCase() ?? 'A', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post['authorName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(_formatTimestamp(widget.post['createdAt']), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),
          if (widget.post['mediaUrl'] != null && widget.post['mediaType'] == 'image')
            Image.network(widget.post['mediaUrl'], 
            width: double.infinity, 
            fit: BoxFit.cover, 
            errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[300], 
            child: const Center(child: Icon(Icons.broken_image, size: 50))))
          else if (widget.post['mediaType'] == 'video' && _isVideoInitialized)
            AspectRatio(aspectRatio: _videoController!.value.aspectRatio, 
            child: Stack(alignment: Alignment.center, 
            children: [VideoPlayer(_videoController!), 
            IconButton(icon: Icon(_videoController!.value.isPlaying ? 
            Icons.pause_circle_outline : 
            Icons.play_circle_outline, size: 64, color: Colors.white), 
            onPressed: () => setState(() => _videoController!.value.isPlaying ? 
            _videoController!.pause() : _videoController!.play()))]))
          else if (widget.post['mediaType'] == 'video')
            Container(height: 200, color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}),
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(widget.post['content'] ?? '', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
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
  // ignore: unused_field
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to limit drag area
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
    
            Opacity(
              opacity: 0.9,
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
          ],
        ),
      ),
    );
  }
}
