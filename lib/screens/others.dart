import 'package:flutter/material.dart';
import 'othersdetail/academic_feature.dart';
import 'othersdetail/mental_health_page.dart';
import 'othersdetail/leaderboard_page.dart';
import 'othersdetail/cultural_tech_page.dart';

class OthersScreen extends StatelessWidget {
  const OthersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of menu items with icons and titles
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Study & Academic',
        'icon': Icons.school,
        'color': Colors.blue,
        'page': const AcademicFeature(),
      },
      {
        'title': 'Mental Health & Wellness',
        'icon': Icons.self_improvement,
        'color': Colors.green,
        'page': const MentalHealthPage(),
      },
      {
        'title': 'Leaderboard',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
        'page': const LeaderboardPage(),
      },
      {
        'title': 'Cultural + Tech Society',
        'icon': Icons.people,
        'color': Colors.purple,
        'page': const CulturalTechPage(),
      },
      ];

    return Scaffold(
      appBar: AppBar(title: const Text('Others')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => menuItems[index]['page'] as Widget,
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        (menuItems[index]['color'] as Color).withOpacity(0.7),
                        menuItems[index]['color'] as Color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        menuItems[index]['icon'] as IconData,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        menuItems[index]['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
