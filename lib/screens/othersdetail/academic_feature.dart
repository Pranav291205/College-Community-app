import 'package:community_app/screens/othersdetail/academics_screens/civil_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/csit_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/ece_block.dart';
import 'package:community_app/screens/othersdetail/academics_screens/mechanical_block.dart';
import 'package:flutter/material.dart';


class AcademicFeature extends StatelessWidget {
  const AcademicFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'AKGEC Academics',
    style: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w900, // visibly bold
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
          Color(0xFF09276D), // deep AKGEC blue
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
          // Full background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/academics.jpg'), //  your JPG path
                fit: BoxFit.cover, // makes it cover full screen
              ),
            ),
          ),

          //  Grid content on top of background
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                shrinkWrap: true,
                children: [
                  _buildFeatureBlock(
                    context,
                    title: 'CS/IT-Block',
                    color: Colors.orange.withOpacity(0.85),
                    page: const CsitBlock(),
                  ),
                  _buildFeatureBlock(
                    context,
                    title: 'ME-Block',
                    color: Colors.teal.withOpacity(0.85),
                    page: const MechanicalBlock(),
                  ),
                  _buildFeatureBlock(
                    context,
                    title: 'Civil-Block',
                    color: Colors.blue.withOpacity(0.85),
                    page: const CivilBlock(),
                  ),
                  _buildFeatureBlock(
                    context,
                    title: 'ECE-Block',
                    color: Colors.purple.withOpacity(0.85),
                    page: const EceBlock(),
                  ),
                ],
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
      fontSize: 22, // slightly larger for visibility
      fontWeight: FontWeight.w900, // extra bold
      letterSpacing: 1.3, // adds a clean modern feel
      shadows: [
        Shadow(
          color: Colors.black54, // subtle text glow
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
