import 'dart:ui';
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
      imageAsset: 'assets/images/n1.jpeg',
    ),
    Professional(
      name: 'Manipal Hospitals - Psychiatry (Ghaziabad)',
      role: 'Consultant Psychiatry',
      phone: '0120-353 5353',
      email: 'contact@manipalhospitals.com',
      imageAsset: 'assets/images/n2.jpeg',
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Mental Health & Wellness',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 22,
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
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff3E1E68),
                  Color(0xff2B1055),
                  Color(0xff120A2A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Scrollable Content
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _sectionHeader('🧠 Mental Health Professionals'),
              const SizedBox(height: 10),
              ...professionals.map((p) => _glassProfessionalCard(context, p)),
              const SizedBox(height: 30),
              _sectionHeader('🎓 Career Guidance & Programs'),
              const SizedBox(height: 10),
              ...programs.map((p) => _glassProgramCard(context, p)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Glassmorphic Professional Card
  Widget _glassProfessionalCard(BuildContext context, Professional p) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    p.imageAsset,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.white.withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.role,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📞 ${p.phone}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      if (p.email.isNotEmpty && p.email != '—') ...[
                        const SizedBox(height: 2),
                        Text(
                          '✉️ ${p.email}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glassmorphic Program Card
  Widget _glassProgramCard(BuildContext context, Program pr) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    pr.imageAsset,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.white.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                // Text Details
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pr.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pr.details,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
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
