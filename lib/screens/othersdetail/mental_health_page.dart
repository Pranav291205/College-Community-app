import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Professional {
  final String name;
  final String role;
  final String phone;
  final String email;
  final String imageAsset;

  Professional({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.imageAsset,
  });
}

class Program {
  final String title;
  final String details;
  final String imageAsset;

  Program({
    required this.title,
    required this.details,
    required this.imageAsset,
  });
}

final professionalsProvider = Provider<List<Professional>>((ref) {
  return [
    Professional(
      name: 'Max Super Speciality Hospital - Psychiatry (Vaishali)',
      role: 'Hospital Psychiatry Department',
      phone: '+91 92688-80303',
      email: 'info@maxhealthcare.com',
      imageAsset: 'assets/images/n1.png',
    ),
    Professional(
      name: 'Manipal Hospitals - Psychiatry (Ghaziabad)',
      role: 'Consultant Psychiatry',
      phone: '0120-353 5353',
      email: 'contact@manipalhospitals.com',
      imageAsset: 'assets/images/n2.webp',
    ),
    Professional(
      name: 'Tara Neuro Psychiatry Clinic (Raj Nagar Ext.)',
      role: 'Clinic / Psychiatrist',
      phone: '+91 74117 97067',
      email: 'tara.neuro@example.com',
      imageAsset: 'assets/images/n3.jpeg',
    ),
    Professional(
      name: 'Dr. Anubhav Dua (Psychiatrist, Vaishali)',
      role: 'Psychiatrist',
      phone: 'Available on Practo listings',
      email: '—',
      imageAsset: 'assets/images/n4.jpeg',
    ),
  ];
});

final programsProvider = Provider<List<Program>>((ref) {
  return [
    Program(
      title: 'College Career Guidance Cell (MMH College)',
      details:
          'Interactive workshops and one-on-one mentoring sessions for students seeking mental health or career advice.',
      imageAsset: 'assets/images/n5.jpeg',
    ),
    Program(
      title: 'Career Counseling Workshops (Ghaziabad)',
      details:
          'Annual sessions by experts from MindGroom and Edumilestones, helping students plan their future careers.',
      imageAsset: 'assets/images/n6.jpeg',
    ),
  ];
});

class MentalHealthPage extends ConsumerWidget {
  const MentalHealthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionals = ref.watch(professionalsProvider);
    final programs = ref.watch(programsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: Text(
          'Mental Health & Wellness',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('🧠 Mental Health Professionals'),
          const SizedBox(height: 10),
          ...professionals.map((p) => _professionalCard(context, p)).toList(),
          const SizedBox(height: 24),
          _sectionHeader('🎓 Career Guidance & Programs'),
          const SizedBox(height: 10),
          ...programs.map((p) => _programCard(context, p)).toList(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.indigo[800],
        ),
      ),
    );
  }

  Widget _professionalCard(BuildContext context, Professional p) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                p.imageAsset,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 60, color: Colors.indigo),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.role,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📞 ${p.phone}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.indigo,
                    ),
                    softWrap: true,
                  ),
                  if (p.email.isNotEmpty && p.email != '—') ...[
                    const SizedBox(height: 2),
                    Text(
                      '✉️ ${p.email}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.indigo[700],
                      ),
                      softWrap: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _programCard(BuildContext context, Program pr) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              pr.imageAsset,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: Colors.indigo.withOpacity(0.05),
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pr.details,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
