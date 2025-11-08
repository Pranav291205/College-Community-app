import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

final recommendedUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  print('📥 Provider: Fetching recommended users');
  return await UserService.getRecommendedUsers();
});

final allUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  print('📥 Provider: Fetching all users');
  return await UserService.getAllUsers();
});
