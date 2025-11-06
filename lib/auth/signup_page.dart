import 'dart:ui';

import 'package:community_app/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedBranch;
  String? _selectedYear;
  List<String> _selectedInterests = [];
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final List<String> branches = [
    "IT",
    "CSE",
    "CS",
    "CSIT",
    "EN",
    "ECE",
    "CIVIL",
    "AIML",
    "CSE(DS)",
    "CSE(AIML)",
    "ME",
    "CS(HINDI)",
  ];

  final List<String> years = ["1st", "2nd", "3rd", "4th"];

  final List<String> interests = [
    "Web Development",
    "Machine Learning",
    "Data Science",
    "Python Programming",
    "App Development",
    "AR / VR",
    "Cloud Computing",
    "Cyber Security",
    "Robotics",
    "Electronics",
    "Mechanical Design",
    "CAD / CAM",
    "Electrical Systems",
    "Embedded Systems",
    "Blockchain",
    "Quantum Computing",
    "Competitive Coding",
    "Hackathons",
    "Research & Innovation",
    "Artificial Intelligence (AI)",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your branch'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your year'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final result = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        branch: _selectedBranch!,
        year: _selectedYear!,
        interests: _selectedInterests,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        if (result['data']?['token'] != null) {
          PostService.setAuthToken(result['data']['token']);
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBarPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showInterestsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelected = List.from(_selectedInterests);
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Your Interests'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final interest = interests[index];
                    return CheckboxListTile(
                      dense: true,
                      title: Text(
                        interest,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: tempSelected.contains(interest),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelected.add(interest);
                          } else {
                            tempSelected.remove(interest);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedInterests = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // ✅ Animated Dark Blue Gradient Background
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 5),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xff0A192F), // Dark Navy
                    Color(0xff172A45), // Deep Blue
                    Color(0xff1F4068), // Classic Dark Blue
                    Color(0xff0A192F), // Loop Back
                  ],
                  stops: [0.0, value * 0.4, value * 0.8, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),

        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                         SizedBox(
                          height: 130,
                           width: 130,
                            child: Lottie.network(
                                 'https://assets5.lottiefiles.com/packages/lf20_tno6cg2w.json', // Tech animation
                                 fit: BoxFit.contain,
                               repeat: true,
                              ),
                               ),


                          const SizedBox(height: 10),
                          const Text(
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Join the AKGEC community 🚀",
                            style: TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 25),

                          _buildTextField(
                            controller: _nameController,
                            hint: "Full Name",
                            icon: Icons.person,
                          ),

                          _buildTextField(
                            controller: _emailController,
                            hint: "yourname@akgec.ac.in",
                            icon: Icons.email,
                            inputType: TextInputType.emailAddress,
                          ),

                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                          ),

                          const SizedBox(height: 18),

                          _buildDropdown("Select Branch", Icons.school, branches, _selectedBranch, (v) {
                            setState(() => _selectedBranch = v);
                          }),

                          const SizedBox(height: 18),

                          _buildDropdown("Select Year", Icons.calendar_today, years, _selectedYear, (v) {
                            setState(() => _selectedYear = v);
                          }),

                          const SizedBox(height: 18),

                          GestureDetector(
                            onTap: _showInterestsDialog,
                            child: _buildGlassTile(
                              icon: Icons.interests,
                              text: _selectedInterests.isEmpty
                                  ? "Choose Interests (Optional)"
                                  : "${_selectedInterests.length} Selected",
                            ),
                          ),

                          if (_selectedInterests.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                spacing: 8,
                                children: _selectedInterests
                                    .map((e) => Chip(
                                          backgroundColor: Colors.blueGrey.shade900,
                                          label: Text(e, style: const TextStyle(color: Colors.white)),
                                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                                          onDeleted: () {
                                            setState(() => _selectedInterests.remove(e));
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _signup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1F4068),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool isPassword = false,
  TextInputType inputType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Widget _buildDropdown(String hint, IconData icon, List<String> items, String? value, Function(String?) onChanged) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Colors.blue.shade200,
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        border: InputBorder.none,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _buildGlassTile({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      ],
    ),
  );
}

}
