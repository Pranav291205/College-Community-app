import 'package:community_app/navbar.dart';
import 'package:community_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedBranch;
  String? _selectedYear;
  List<String> _selectedInterests = [];
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final branches = [
    "IT", "CSE", "CS", "CSIT", "EN", "ECE", "CIVIL", "AIML", 
    "CSE(DS)", "CSE(AIML)", "ME", "CS(HINDI)",
  ];

  final years = ["1st", "2nd", "3rd", "4th"];

  final interests = [
    "Artificial Intelligence (AI)", "Machine Learning", "Data Science", "Python Programming",
    "Web Development", "App Development", "AR / VR", "Cloud Computing", "Cyber Security",
    "Robotics", "Electronics", "Mechanical Design", "CAD / CAM", "Electrical Systems",
    "Embedded Systems", "Blockchain", "Quantum Computing", "Competitive Coding",
    "Hackathons", "Research & Innovation",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate() && _selectedBranch != null && _selectedYear != null) {
      ref.read(registerProvider({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'branch': _selectedBranch,
        'year': _selectedYear,
        'interests': _selectedInterests,
      })).when(
        data: (result) {
          if (result['success']) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavBarPage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
            );
          }
        },
        loading: () {},
        error: (err, __) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text('Create Account', 
              style: TextStyle(fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.blue)),
              const SizedBox(height: 30),
              TextFormField(controller: _nameController, 
              decoration: InputDecoration(labelText: 'Full Name', 
              prefixIcon: const Icon(Icons.person), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _emailController, 
              keyboardType: TextInputType.emailAddress, 
              decoration: InputDecoration(labelText: 'AKGEC Email', 
              prefixIcon: const Icon(Icons.email), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              validator: (v) => !v!.endsWith('@akgec.ac.in') ?? true ? 'Use AKGEC email' : null),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(value: _selectedBranch, 
              decoration: InputDecoration(labelText: 'Branch', 
              prefixIcon: const Icon(Icons.school), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              items: branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(), 
              onChanged: (v) => setState(() => _selectedBranch = v)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(value: _selectedYear, 
              decoration: InputDecoration(labelText: 'Year', 
              prefixIcon: const Icon(Icons.calendar_today), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y Year'))).toList(), 
              onChanged: (v) => setState(() => _selectedYear = v)),
              const SizedBox(height: 20),
              TextFormField(controller: _passwordController, 
              obscureText: !_isPasswordVisible, 
              decoration: InputDecoration(labelText: 'Password', 
              prefixIcon: const Icon(Icons.lock), 
              suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), 
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _confirmPasswordController, 
              obscureText: !_isConfirmPasswordVisible, 
              decoration: InputDecoration(labelText: 'Confirm Password', 
              prefixIcon: const Icon(Icons.lock_outline), 
              suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? 
              Icons.visibility : Icons.visibility_off), 
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
              validator: (v) => v != _passwordController.text ? 'Passwords mismatch' : null),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, 
              height: 50, child: ElevatedButton(onPressed: _signup, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
              child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, 
              children: [const Text("Have account? "), 
              TextButton(onPressed: () => Navigator.pop(context), 
              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)))]),
            ],
          ),
        ),
      ),
    );
  }
}
