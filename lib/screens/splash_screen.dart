import 'dart:async';
import 'package:community_app/navbar.dart';
import 'package:community_app/providers/auth_notifier.dart';
import 'package:community_app/services/post_service.dart';
import 'package:community_app/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lottie/lottie.dart';
import '../auth/login_page.dart';

final typewriterTextProvider = StateNotifierProvider<TypewriterTextNotifier, String>(
  (ref) => TypewriterTextNotifier(),
);

class TypewriterTextNotifier extends StateNotifier<String> {
  TypewriterTextNotifier() : super('');

  Timer? _timer;
  final String fullText = 'Connecting Students & Faculty';
  int textIndex = 0;

  void startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (textIndex < fullText.length) {
        state = state + fullText[textIndex];
        textIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    ref.read(typewriterTextProvider.notifier).startTyping();
    _checkAuthAndNavigate();
}

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedText = ref.watch(typewriterTextProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF00B4DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/college_loader.json',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'College Community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  displayedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _checkAuthAndNavigate() async {
  await PostService.loadToken();
  if (PostService.authToken != null && PostService.authToken!.isNotEmpty) {
    ref.read(authTokenProvider.notifier).setToken(PostService.authToken!);
    print('✅ Riverpod provider updated with loaded token');
  }

  await Future.delayed(const Duration(seconds: 5));

  if (!mounted) return;

  if (PostService.authToken != null && PostService.authToken!.isNotEmpty) {
    print('✅ User is already logged in');
    await SocketService.connect();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const NavBarPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  } else {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
}
