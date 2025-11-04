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
        title: const Text('College Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(postsProvider),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) => posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No posts yet', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(postsProvider).future,
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(post: posts[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

extension on AsyncValue<List> {
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
