import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_service.dart';

final postsProvider = FutureProvider<List<dynamic>>((ref) async {
  return await PostService.getAllPosts();
});

final createPostProvider = FutureProvider.family<Map<String, dynamic>, ({
  String title,
  String content,
  File? mediaFile,
  String? mediaType,
  String? authorName,
})>((ref, params) async {
  final result = await PostService.createPost(
    title: params.title,
    content: params.content,
    mediaFile: params.mediaFile,
    mediaType: params.mediaType,
    authorName: params.authorName,
  );
  
  if (result['success']) {
    ref.refresh(postsProvider);
  }
  
  return result;
});
