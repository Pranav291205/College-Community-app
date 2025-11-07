import 'package:flutter/material.dart';

class SocietiesPage extends StatelessWidget {
  const SocietiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data for 9 societies with their event photos
    final societies = [
      {
        'name': 'Euphony',
        'description': 'Innovation and Technology',
        'color': Colors.blue,
        'photos': [
          'assets/e1.png',
          'assets/e2.png',
          'assets/e3.png',
          'assets/e4.png',
        ],
      },
      {
        'name': 'Taal',
        'description': 'Art, Music and Dance',
        'color': Colors.purple,
        'photos': [
          'assets/t1.jpg',
          'assets/t2.jpg',
          'assets/t3.jpg',
          'assets/t4.jpeg',
        ],
      },
      {
        'name': 'Verv',
        'description': 'Athletics and Fitness',
        'color': Colors.orange,
        'photos': [
          'assets/v1.jpg',
          'assets/v2.jpg',
          'assets/v3.jpg',
          'assets/v4.jpeg',
        ],
      },
      {
        'name': 'Goonj',
        'description': 'Reading and Writing',
        'color': Colors.teal,
        'photos': [
          'assets/g1.jpg',
          'assets/g2.jpg',
          'assets/g3.jpg',
          'assets/g4.jpg',
        ],
      },
      {
        'name': 'Footprint',
        'description': 'Business and Startups',
        'color': Colors.green,
        'photos': [
          'assets/f1.png',
          'assets/f2.png',
          'assets/f3.png',
          'assets/f4.png',
        ],
      },
      {
        'name': 'Photography Society',
        'description': 'Visual Arts and Media',
        'color': Colors.red,
        'photos': [
          'assets/p1.jpg',
          'assets/p2.jpg',
          'assets/p3.jpg',
          'assets/p4.jpg',
        ],
      },
      {
        'name': 'Sports Club',
        'description': 'Automation and AI',
        'color': Colors.indigo,
        'photos': [
          'assets/s1.jpg',
          'assets/s2.jpg',
          'assets/s3.jpg',
          'assets/s4.jpg',
        ],
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
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'College Societies',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: societies.length,
        itemBuilder: (context, index) {
          return _buildSocietySection(
            societies[index]['name'] as String,
            societies[index]['description'] as String,
            societies[index]['color'] as Color,
            societies[index]['photos'] as List<String>,
          );
        },
      ),
    );
  }

  Widget _buildSocietySection(
    String societyName,
    String description,
    Color color,
    List<String> photos,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Society Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSocietyIcon(societyName),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        societyName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Event Photos - Horizontal Scroll
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, photoIndex) {
                return _buildPhotoCard(photos[photoIndex], photoIndex, color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String photoPath, int index, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Photo Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 280,
              height: 200,
              color: Colors.grey[200],
              child: Image.asset(
                photoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback design if image not found
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Event Photo ${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Photo Index Badge
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

          // Gradient Overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Event Highlight ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocietyIcon(String societyName) {
    switch (societyName) {
      case 'Technical Society':
        return Icons.computer;
      case 'Cultural Society':
        return Icons.music_note;
      case 'Sports Society':
        return Icons.sports_basketball;
      case 'Literary Society':
        return Icons.book;
      case 'Entrepreneurship Cell':
        return Icons.business;
      case 'Photography Society':
        return Icons.camera_alt;
      case 'Robotics Club':
        return Icons.precision_manufacturing;
      case 'Drama Society':
        return Icons.theater_comedy;
      case 'Social Service Club':
        return Icons.volunteer_activism;
      default:
        return Icons.group;
    }
  }
}
