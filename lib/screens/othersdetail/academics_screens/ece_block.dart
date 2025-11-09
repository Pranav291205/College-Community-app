import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eceFacultyListProvider = Provider<List<Map<String, String>>>((ref) {
  return const [
    {
      'name': 'Dr. Neelesh Gupta',
      'image': 'assets/images/neelesh.jpg',
      'experience': '20 Years',
      'subject': 'HOD'
    },
    {
      'name': 'Dr. Himani Garg',
      'image': 'assets/images/himani.jpg',
      'experience': '15 Years',
      'subject': 'Professor/Dean'
    },
    {
      'name': 'Dr. Monika Jain',
      'image': 'assets/images/monika.jpg',
      'experience': '15 Years',
      'subject': 'Professor'
    },
    {
      'name': 'Dr. Amit Garg',
      'image': 'assets/images/amit.jpg',
      'experience': '8 Years',
      'subject': 'Assistant Professor'
    },
    {
      'name': 'Dr. Jitender Chhabra',
      'image': 'assets/images/jit.jpg',
      'experience': '2 Years',
      'subject': 'Assistant Professor'
    },
    {
      'name': 'Dr. Karunesh',
      'image': 'assets/images/karun.jpg',
      'experience': '6 Years',
      'subject': 'Assistant Professor'
    },
    {
      'name': 'Dr. Gaurav Saxena',
      'image': 'assets/images/gaurav.jpg',
      'experience': '6 Years',
      'subject': 'Assistant Professor'
    },
  ];
});

class EceBlock extends ConsumerWidget {
  const EceBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultyList = ref.watch(eceFacultyListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ECE Faculty',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black45,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF09276D),
                Color(0xFF1661B2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78, 
          ),
          itemCount: facultyList.length,
          itemBuilder: (context, index) {
            final faculty = facultyList[index];
            return _buildFacultyCard(
              name: faculty['name']!,
              imagePath: faculty['image']!,
              experience: faculty['experience']!,
              subject: faculty['subject']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFacultyCard({
    required String name,
    required String imagePath,
    required String experience,
    required String subject,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D47A1),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            subject,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            'Experience: $experience',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
