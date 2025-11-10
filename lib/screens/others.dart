import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'othersdetail/academic_feature.dart';
import 'othersdetail/mental_health_page.dart';
import 'othersdetail/leaderboard_page.dart';
import 'othersdetail/cultural_tech_page.dart';

final menuItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': 'Study & Academic',
      'icon': Icons.school_rounded,
      'color': const Color(0xff4A90E2),
      'page': const AcademicFeature(),
    },
    {
      'title': 'Mental Health & Wellness',
      'icon': Icons.spa_rounded,
      'color': const Color(0xff2ECC71),
      'page': const MentalHealthPage(),
    },
    {
      'title': 'Leaderboard',
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xffF39C12),
      'page': const LeaderboardPage(),
    },
    {
      'title': 'Cultural + Tech Society',
      'icon': Icons.groups_rounded,
      'color': const Color(0xff9B59B6),
      'page': const SocietiesPage(),
    },
  ];
});

class OthersScreen extends ConsumerStatefulWidget {
  const OthersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends ConsumerState<OthersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFloatingGlow({
    required double size,
    required double x,
    required double y,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: x + sin(_controller.value * 2 * pi) * 20,
          top: y + cos(_controller.value * 2 * pi) * 20,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                radius: 0.9,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "CollabSpace",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
            colors: [
                Color.fromARGB(166, 18, 4, 143),  // 65% transparent gradient
                Color.fromARGB(166, 63, 11, 126),
              ],
              colors: [Color(0xff5B2C6F), Color(0xff6A1B9A), Color(0xff4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 76, 48, 191),
                      Color.fromARGB(255, 0, 0, 0),
                    ],
                  Color(0xff3E1E68),
                  Color(0xff2B1055),
                  Color(0xff120A2A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Floating glow effects
          _buildFloatingGlow(size: 130, x: 40, y: 120),
          _buildFloatingGlow(size: 180, x: 250, y: 250),
          _buildFloatingGlow(size: 100, x: 80, y: 480),
          _buildFloatingGlow(size: 160, x: 200, y: 620),

          // Main grid content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 110, 18, 18),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.95,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final color = item['color'] as Color;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page'] as Widget),
                  ),
                  child: _buildMenuTile(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    color: color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.25),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(icon, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 14),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Decorative line
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
