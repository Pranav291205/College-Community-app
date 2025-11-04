import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);

final loginProvider = FutureProvider.family<Map<String, dynamic>, (String, String)>(
  (ref, params) async {
    final result = await AuthService.login(
      email: params.$1,
      password: params.$2,
    );
    
    if (result['success']) {
      ref.read(authTokenProvider.notifier).state = result['data']['token'];
    }
    
    return result;
  },
);

final registerProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final result = await AuthService.register(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      branch: data['branch'],
      year: data['year'],
      interests: data['interests'],
    );
    
    if (result['success']) {
      ref.read(authTokenProvider.notifier).state = result['data']['token'];
    }
    
    return result;
  },
);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authTokenProvider) != null;
});
