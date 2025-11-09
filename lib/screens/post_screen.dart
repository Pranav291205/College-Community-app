import 'dart:io';
import 'dart:ui';
import 'package:community_app/widgets/multi_select_categories_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/user_posts_provider.dart' hide userPostsProvider;
import '../providers/auth_notifier.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _mediaFile;
  bool _isLoading = false;
  String? _error;
  List<String> _selectedCategories = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
  try {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 26,
                        ),
                      ),
                      title: const Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Take a new photo'),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                    
                    const Divider(height: 1),
                    
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.green,
                          size: 26,
                        ),
                      ),
                      title: const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Choose from gallery'),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                    
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _error = null;
        });
        print('📸 Image selected from ${source == ImageSource.camera ? "Camera" : "Gallery"}: ${pickedFile.name}');
      }
    }
  } catch (e) {
    print('❌ Error picking image: $e');
    
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


  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a description');
      return;
    }

    if (_selectedCategories.isEmpty) {
      setState(() => _error = 'Please select at least one category');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categoryString = _selectedCategories.join(', ');
      
      print('📝 Creating post...');
      print('   Title: ${_titleController.text}');
      print('   Description: ${_descriptionController.text}');
      print('   Category: $categoryString');
      print('   Has media: ${_mediaFile != null}');

      final postFormNotifier = ref.read(postFormProvider.notifier);

      postFormNotifier.setTitle(_titleController.text.trim());
      postFormNotifier.setDescription(_descriptionController.text.trim());
      postFormNotifier.setCategory(categoryString); // Send as comma-separated string

      if (_mediaFile != null) {
        postFormNotifier.setMediaFile(_mediaFile);
      }

      final result = await postFormNotifier.submitPost();

      print('📊 Submit result: $result');

      setState(() => _isLoading = false);

      if (result['success']) {
        print('✅ Post created successfully!');

        _titleController.clear();
        _descriptionController.clear();

        setState(() {
          _mediaFile = null;
          _selectedCategories = [];
          _error = null;
        });
        
        ref.refresh(postsProvider);
        print('🔄 All posts refreshed');

        ref.refresh(userPostsProvider);
        print('🔄 User posts refreshed');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        String errorMsg = result['message'] ?? 'Failed to create post';
        print('❌ Error: $errorMsg');

        setState(() => _error = errorMsg);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMsg'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });

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

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);

    print('🔍 PostScreen build - Token: ${token?.substring(0, 20) ?? "null"}...');

    if (token == null || token.isEmpty) {
      print('❌ Not logged in - showing login prompt');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Please login to create posts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    print('✅ Logged in - showing post form');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 7, 63, 126),
                    Color(0xFF6FB1FC),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: AnimatedShimmerText(
                  text: 'Create Post',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedGradientBackground(),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Title',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    prefixIcon: const Icon(Icons.title, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '${_titleController.text.length}/100',
                  ),
                  maxLength: 100,
                  enabled: !_isLoading,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Tell us more...',
                    prefixIcon: const Icon(Icons.description, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    alignLabelWithHint: true,
                    counterText: '${_descriptionController.text.length}/500',
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  enabled: !_isLoading,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Categories *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                MultiSelectCategoriesDropdown(
                  selectedCategories: _selectedCategories,
                  onChanged: (selected) {
                    setState(() {
                      _selectedCategories = selected;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (_mediaFile != null) ...[
                  const Text(
                    'Media Preview',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _mediaFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _isLoading ? null : () => setState(() => _mediaFile = null),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate,
                            color: Colors.blue.shade700,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mediaFile == null ? 'Add Photo' : 'Change Photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Text(
                                'Choose from gallery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Post Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _alignmentAnimation.value,
              end: Alignment.center,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade500,
                Colors.blue.shade700,
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;

  const AnimatedShimmerText({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 1.0,
  }) : super(key: key);

  @override
  State<AnimatedShimmerText> createState() => _AnimatedShimmerTextState();
}

class _AnimatedShimmerTextState extends State<AnimatedShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                Colors.white,
                Colors.blue.shade100,
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.white,
              letterSpacing: widget.letterSpacing,
            ),
          ),
        );
      },
    );
  }
}
