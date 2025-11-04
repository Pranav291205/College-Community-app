import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../providers/post_provider.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  
  File? _mediaFile;
  String? _mediaType;
  VideoPlayerController? _videoController;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _mediaType = isVideo ? 'video' : 'image';
        });

        if (isVideo) {
          _videoController = VideoPlayerController.file(_mediaFile!)..initialize().then((_) => setState(() {}));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.photo_library, color: Colors.blue), 
          title: const Text('Gallery - Image'), 
          onTap: () { Navigator.pop(context); _pickMedia(ImageSource.gallery, false); }),
          ListTile(leading: const Icon(Icons.photo_camera, color: Colors.blue), 
          title: const Text('Camera - Image'), 
          onTap: () { Navigator.pop(context); _pickMedia(ImageSource.camera, false); }),
          ListTile(leading: const Icon(Icons.video_library, color: Colors.purple), 
          title: const Text('Gallery - Video'), 
          onTap: () { Navigator.pop(context); _pickMedia(ImageSource.gallery, true); }),
          ListTile(leading: const Icon(Icons.videocam, color: Colors.purple), 
          title: const Text('Camera - Video'), 
          onTap: () { Navigator.pop(context); _pickMedia(ImageSource.camera, true); }),
        ]),
      ),
    );
  }

  void _removeMedia() {
    setState(() {
      _mediaFile = null;
      _mediaType = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      ref.read(createPostProvider(
        (
          title: _titleController.text,
          content: _contentController.text,
          mediaFile: _mediaFile,
          mediaType: _mediaType,
          authorName: 'Current User',
        ),
      )).when(
        data: (result) {
          setState(() => _isLoading = false);
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
            _titleController.clear();
            _contentController.clear();
            _removeMedia();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
          }
        },
        loading: () {},
        error: (err, __) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Share your thoughts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
              const SizedBox(height: 24),
              TextFormField(controller: _titleController, 
              decoration: InputDecoration(labelText: 'Title', prefixIcon: const Icon(Icons.title), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              validator: (v) => (v?.length ?? 0) < 3 ? 'Min 3 chars' : null, maxLength: 100),
              const SizedBox(height: 20),
              TextFormField(controller: _contentController, 
              decoration: InputDecoration(labelText: 'Content', prefixIcon: const Icon(Icons.description), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
              alignLabelWithHint: true), 
              maxLines: 5, 
              maxLength: 500, 
              validator: (v) => (v?.length ?? 0) < 10 ? 'Min 10 chars' : null),
              const SizedBox(height: 20),
              if (_mediaFile != null) ...[
                Stack(children: [
                  Container(height: 300, 
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.grey)), 
                  child: ClipRRect(borderRadius: BorderRadius.circular(12), 
                  child: _mediaType == 'image' ? 
                  Image.file(_mediaFile!, fit: BoxFit.cover) : 
                  _videoController != null && _videoController!.value.isInitialized ? 
                  AspectRatio(aspectRatio: _videoController!.value.aspectRatio, 
                  child: VideoPlayer(_videoController!)) : 
                  const Center(child: CircularProgressIndicator()))),
                  Positioned(top: 8, right: 8, 
                  child: IconButton(icon: const Icon(Icons.close, color: Colors.white), 
                  style: IconButton.styleFrom(backgroundColor: Colors.black54), 
                  onPressed: _removeMedia)),
                  if (_mediaType == 'video' && _videoController != null && _videoController!.value.isInitialized)
                    Positioned(bottom: 8, right: 8, 
                    child: IconButton(icon: Icon(_videoController!.value.isPlaying ? 
                    Icons.pause : 
                    Icons.play_arrow, color: Colors.white), 
                    style: IconButton.styleFrom(backgroundColor: Colors.black54), 
                    onPressed: () => setState(() => 
                    _videoController!.value.isPlaying ? 
                    _videoController!.pause() : 
                    _videoController!.play()))),
                ]),
                const SizedBox(height: 20),
              ],
              OutlinedButton.icon(onPressed: _showMediaOptions, 
              icon: const Icon(Icons.add_photo_alternate), 
              label: Text(_mediaFile == null ? 
              'Add Photo/Video' : 
              'Change Photo/Video'), 
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? 
                  const SizedBox(width: 24, height: 24, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : 
                  const Text('Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
