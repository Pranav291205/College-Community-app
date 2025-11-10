import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

// Provider for all societies data
final societiesProvider = Provider<Map<String, List<Map<String, dynamic>>>>((ref) {
  return {
    'cultural': [
      {
        'name': 'Euphony',
        'description': 'Music',
        'color': Colors.blue,
        'photos': [
          'assets/e1.png',
          'assets/e2.png',
          'assets/e3.png',
          'assets/e4.png',
        ],
        'insta': 'https://www.instagram.com/euphony_akgec/',
      },
      {
        'name': 'Taal',
        'description': 'Dance',
        'color': Colors.purple,
        'photos': [
          'assets/t1.jpg',
          'assets/t2.jpg',
          'assets/t3.jpg',
          'assets/t4.jpeg',
        ],
        'insta': 'https://www.instagram.com/taalscrew/?hl=en',
      },
      {
        'name': 'Verv',
        'description': 'Modelling',
        'color': Colors.orange,
        'photos': [
          'assets/v1.jpg',
          'assets/v2.jpg',
          'assets/v3.jpg',
          'assets/v4.jpeg',
        ],
        'insta': 'https://www.instagram.com/verve_fashion_team/?hl=en',
      },
      {
        'name': 'Goonj',
        'description': 'Theatre and Performance',
        'color': Colors.teal,
        'photos': [
          'assets/g1.jpg',
          'assets/g2.jpg',
          'assets/g3.jpg',
          'assets/g4.jpg',
        ],
        'insta': 'https://www.instagram.com/goonj.akg/?hl=en',
      },
      {
        'name': 'Footprint',
        'description': 'Art Society',
        'color': Colors.green,
        'photos': [
          'assets/f1.png',
          'assets/f2.png',
          'assets/f3.png',
          'assets/f4.png',
        ],
        'insta': 'https://www.instagram.com/kaleidoscope.fp/',
      },
      {
        'name': 'Photography Society',
        'description': 'Photography and Media',
        'color': Colors.red,
        'photos': [
          'assets/p1.jpg',
          'assets/p2.jpg',
          'assets/p3.jpg',
          'assets/p4.jpg',
        ],
        'insta': 'https://www.instagram.com/photography_society/',
      },
      {
        'name': 'Sports Club',
        'description': 'Sports',
        'color': Colors.indigo,
        'photos': [
          'assets/s1.jpg',
          'assets/s2.jpg',
          'assets/s3.jpg',
          'assets/s4.jpg',
        ],
        'insta': 'https://www.instagram.com/sports_club/',
      },
      {
        'name': 'Horizon',
        'description': 'Theatre and Performance',
        'color': Colors.pink,
        'photos': [
          'assets/h1.jpg',
          'assets/h2.jpg',
          'assets/h3.jpg',
          'assets/h4.jpg',
        ],
        'insta': 'https://www.instagram.com/horizon.akgec/?hl=en',
      },
      {
        'name': 'Renaissance',
        'description': 'Community Welfare',
        'color': Colors.amber,
        'photos': [
          'assets/r1.jpg',
          'assets/r2.jpg',
          'assets/r3.jpg',
          'assets/r4.jpg',
        ],
        'insta': 'https://www.instagram.com/renaissance_society/',
      },
    ],
    'technical': [
      {
        'name': 'Blockchain Research Lab',
        'description': 'Development and Innovation',
        'color': Colors.blueAccent,
        'photos': [
          'assets/b1.jpg',
          'assets/b2.jpg',
          'assets/b3.jpg',
          'assets/b4.jpg',
        ],
        'insta': 'https://www.instagram.com/brl_akgec/',
      },
      {
        'name': 'Software Incubator',
        'description': 'Research and Development',
        'color': Colors.deepPurple,
        'photos': [
          'assets/si1.jpg',
          'assets/si2.jpg',
          'assets/si3.jpg',
          'assets/si4.jpg',
        ],
        'insta': 'https://www.instagram.com/software.incubator/?hl=en',
      },
      {
        'name': 'Big Data Centre of Excellence',
        'description': 'Research and Development centre',
        'color': Colors.orangeAccent,
        'photos': [
          'assets/bd1.jpg',
          'assets/bd2.jpg',
          'assets/bd3.jpg',
          'assets/bd4.jpg',
        ],
        'insta': 'https://www.instagram.com/bdcoe/?hl=en',
      },
      {
        'name': 'Machine learning center of excellence',
        'description': 'Artificial Intelligence and Data Science',
        'color': Colors.teal,
        'photos': [
          'assets/m1.jpg',
          'assets/m2.jpg',
          'assets/m3.jpg',
          'assets/m4.jpg',
        ],
        'insta': 'https://www.instagram.com/mlcoe_akgec/',
      },
      {
        'name': 'Computer Society Of India',
        'description': 'Computer Science Society',
        'color': Colors.redAccent,
        'photos': [
          'assets/csi1.jpg',
          'assets/csi2.jpg',
          'assets/csi3.jpg',
          'assets/csi4.jpg',
        ],
        'insta': 'https://www.instagram.com/csi_akgec/?hl=en',
      },
      {
        'name': 'Cloud Computing Cell',
        'description': 'Managing and deploying cloud services',
        'color': Colors.brown,
        'photos': [
          'assets/ccc1.jpg',
          'assets/ccc2.jpg',
          'assets/ccc3.jpg',
          'assets/ccc4.jpg',
        ],
        'insta': 'https://www.instagram.com/ccc_akgec/',
      },
      {
        'name': 'Open Source Software',
        'description': 'Open Source Software Research and Developement Center',
        'color': Colors.green,
        'photos': [
          'assets/oss1.jpg',
          'assets/oss2.jpg',
          'assets/oss3.jpg',
          'assets/oss4.jpg',
        ],
        'insta': 'https://www.instagram.com/team__oss/?hl=en',
      },
      {
        'name': 'Conatus',
        'description': 'Computer Science and IT society',
        'color': Colors.grey,
        'photos': [
          'assets/co1.jpeg',
          'assets/co2.jpeg',
          'assets/co3.jpeg',
          'assets/co4.jpeg',
        ],
        'insta': 'https://www.instagram.com/conatus.akg/',
      },
      {
        'name': 'SAE',
        'description': 'SAE AKGEC Student Formula Team',
        'color': Colors.pinkAccent,
        'photos': [
          'assets/sa1.jpg',
          'assets/sa2.jpg',
          'assets/sa3.jpg',
          'assets/sa4.jpg',
        ],
        'insta': 'https://www.instagram.com/sae_akgec/?hl=en',
      },
    ],
  };
});

final isTechSelectedProvider = StateProvider<bool>((ref) => false);

class SocietiesPage extends ConsumerWidget {
  const SocietiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTechSelected = ref.watch(isTechSelectedProvider);
    final allSocieties = ref.watch(societiesProvider);
    final societies = isTechSelected ? allSocieties['technical']! : allSocieties['cultural']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "College Societies",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3A0CA3),
                  Color(0xFF7209B7),
                  Color(0xFF4361EE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 100),
              _buildToggleSwitch(ref, isTechSelected),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: societies.length,
                  itemBuilder: (context, index) {
                    final s = societies[index];
                    return _buildSocietyCard(
                      s['name'],
                      s['description'],
                      s['color'],
                      s['photos'],
                      s['insta'],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(WidgetRef ref, bool isTechSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                _toggleButton(ref, "Cultural", !isTechSelected, false),
                _toggleButton(ref, "Technical", isTechSelected, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(WidgetRef ref, String text, bool selected, bool isTech) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(isTechSelectedProvider.notifier).state = isTech;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocietyCard(
    String name,
    String desc,
    Color color,
    List<String> photos,
    String instaUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withOpacity(0.3),
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(instaUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Photos
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return _buildPhotoCard(photos[index], index, color);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String photoPath, int index, Color color) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              photoPath,
              width: 260,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: color.withOpacity(0.4),
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
          // Photo counter badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${index + 1}/4',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
