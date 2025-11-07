import 'dart:math';
import 'package:flutter/material.dart';
import 'othersdetail/academic_feature.dart';
import 'othersdetail/mental_health_page.dart';
import 'othersdetail/leaderboard_page.dart';
import 'othersdetail/cultural_tech_page.dart';

class OthersScreen extends StatefulWidget {
  const OthersScreen({Key? key}) : super(key: key);

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBackgroundBubble({
    required double size,
    required double x,
    required double y,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: x + sin(_controller.value * 2 * pi) * 20,
          top: y + cos(_controller.value * 2 * pi) * 20,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
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
        'page': MentalHealthPage(),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EXPLORE",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        toolbarHeight: 65,
        shadowColor: Colors.black54,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1e3c72), Color(0xff2a5298), Color(0xff000428)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ✅ Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff141E30), Color(0xff243B55)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          _buildBackgroundBubble(size: 120, x: 30, y: 80),
          _buildBackgroundBubble(size: 160, x: 250, y: 140),
          _buildBackgroundBubble(size: 90, x: 80, y: 400),
          _buildBackgroundBubble(size: 130, x: 200, y: 550),

          // ✅ Main UI Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['page'] as Widget),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
