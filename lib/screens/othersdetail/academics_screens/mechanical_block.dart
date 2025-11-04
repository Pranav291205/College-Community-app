import 'package:flutter/material.dart';

class MechanicalBlock extends StatelessWidget {
  const MechanicalBlock({super.key});

  // Faculty data list
  final List<Map<String, String>> facultyList = const [
    {
      'name': 'Dr. Pallab Biswas',
      'image': 'assets/images/pallab.jpg',
      'experience': '20 Years',
      'subject': 'HOD'
    },
    {
      'name': 'Prof. I.P. Sharma',
      'image': 'assets/images/ip.jpg',
      'experience': '15 Years',
      'subject': 'Professor/Dean'
    },
    {
      'name': 'Dr. Namrata Gangil',
      'image': 'assets/images/namrata.jpg',
      'experience': '15 Years',
      'subject': 'Professor'
    },
    {
      'name': 'Dr. Devendra Singh',
      'image': 'assets/images/devendra.jpg',
      'experience': '8 Years',
      'subject': 'Professor'
    },
    {
      'name': 'Mr. Ajay Kant Dubey',
      'image': 'assets/images/ajay.jpeg',
      'experience': '2 Years',
      'subject': 'Assistant Professor'
    },
    {
      'name': 'Ms. Gaganpreet Kaur',
      'image': 'assets/images/gagan.jpeg',
      'experience': '6 Years',
      'subject': 'Assistant Professor'
    },
    
     {
      'name': 'Dr. Manoj Yadav',
      'image': 'assets/images/manoj.jpg',
      'experience': '6 Years',
      'subject': 'Assistant Professor'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mechanical Faculty',
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
            crossAxisCount: 2, // two cards in each row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78, // adjust for text & image fit
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

  // Widget builder for each faculty card
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
          // Faculty Image
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

          // Faculty Name
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

          // Subject
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

          // Experience
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
