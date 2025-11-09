import 'package:community_app/screens/othersdetail/academics_screens/civil_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/csit_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/ece_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/mechanical_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final academicBlocksProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': 'CS/IT-Block',
      'color': Colors.orange.withOpacity(0.85),
      'page': const CsitBlock(),
    },
    {
      'title': 'ME-Block',
      'color': Colors.teal.withOpacity(0.85),
      'page': const MechanicalBlock(),
    },
    {
      'title': 'Civil-Block',
      'color': Colors.blue.withOpacity(0.85),
      'page': const CivilBlock(),
    },
    {
      'title': 'ECE-Block',
      'color': Colors.purple.withOpacity(0.85),
      'page': const EceBlock(),
    },
  ];
});

class AcademicFeature extends ConsumerWidget {
  const AcademicFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academicBlocks = ref.watch(academicBlocksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AKGEC Academics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
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
        elevation: 6,
        shadowColor: Colors.black45,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF09276D), 
                Color(0xFF1661B2),
                Color(0xFF09276D),
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
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
      ),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/academics.jpg'), 
                fit: BoxFit.cover, 
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                shrinkWrap: true,
                itemCount: academicBlocks.length,
                itemBuilder: (context, index) {
                  final block = academicBlocks[index];
                  return _buildFeatureBlock(
                    context,
                    title: block['title'] as String,
                    color: block['color'] as Color,
                    page: block['page'] as Widget,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBlock(BuildContext context,
      {required String title, required Color color, required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22, 
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              shadows: [
                Shadow(
                  color: Colors.black54, 
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
