import 'dart:ui';
import 'package:community_app/screens/othersdetail/academics_screens/civil_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/csit_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/ece_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/mechanical_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final academicBlocksProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': 'CS/IT Block',
      'color': const Color(0xFF6C63FF),
      'page': const CsitBlock(),
      'icon': Icons.computer,
    },
    {
      'title': 'Mechanical Block',
      'color': const Color(0xFF00BCD4),
      'page': const MechanicalBlock(),
      'icon': Icons.engineering,
    },
    {
      'title': 'Civil Block',
      'color': const Color(0xFFAB47BC),
      'page': const CivilBlock(),
      'icon': Icons.apartment,
    },
    {
      'title': 'ECE Block',
      'color': const Color(0xFFE91E63),
      'page': const EceBlock(),
      'icon': Icons.memory,
    },
  ];
});

class AcademicFeature extends ConsumerWidget {
  const AcademicFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academicBlocks = ref.watch(academicBlocksProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'AKGEC Academics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff4A148C),
                Color(0xff6A1B9A),
                Color(0xff8E24AA)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/academics.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Lighter gradient overlay to keep image visible
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xff3E1E68).withOpacity(0.6), // 60% opacity
                  const Color(0xff2B1055).withOpacity(0.7), // 70% opacity
                  const Color(0xff120A2A).withOpacity(0.8), // 80% opacity
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Glass cards grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.95,
              ),
              itemCount: academicBlocks.length,
              itemBuilder: (context, index) {
                final block = academicBlocks[index];
                return _buildGlassBlock(
                  context,
                  title: block['title'],
                  color: block['color'],
                  page: block['page'],
                  icon: block['icon'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBlock(
    BuildContext context, {
    required String title,
    required Color color,
    required Widget page,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(3, 6),
                ),
              ],
            ),
            child: InkWell(
              splashColor: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassy icon container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Decorative line
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
