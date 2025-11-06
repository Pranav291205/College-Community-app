import 'dart:ui';

import 'package:community_app/auth/signup_page.dart';
import 'package:community_app/navbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../services/post_service.dart';
import '../providers/auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 Attempting login...');
      print('   Email: ${_emailController.text}');

      final response = await http.post(
        Uri.parse('https://college-community-app-backend.onrender.com/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('📊 Login Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        print('✅ Login successful');
        print('   Token: ${token?.substring(0, 30) ?? "null"}...');

        if (token != null && token.isNotEmpty) {
          PostService.setAuthToken(token);
          ref.read(authTokenProvider.notifier).setToken(token);

          print('✅ Token set in both PostService and Riverpod');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NavBarPage()),
            );
          }
        } else {
          print('❌ No token in response');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login failed: No token')),
            );
          }
        }
      } else {
        final error = jsonDecode(response.body);
        print('❌ Login error: ${error['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${error['message'] ?? "Unknown error"}'),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _skipLogin() {
    print('👤 Skipping login - entering as guest');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavBarPage()),
    );
  }

  void _goToSignUp() {
    print('📝 Navigating to Sign Up');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  void _forgotPassword() {
    print('🔑 Forgot Password clicked');
    _showForgotPasswordDialog();
  }

  void _showForgotPasswordDialog() {
    final _emailForgotController = TextEditingController();
    bool _isSending = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Forgot Password?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailForgotController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'your@email.com',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSending
                      ? null
                      : () async {
                          if (_emailForgotController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your email')),
                            );
                            return;
                          }

                          setState(() => _isSending = true);

                          try {
                            print('📧 Sending password reset email...');
                            // TODO: Implement forgot password API call

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reset link sent to ${_emailForgotController.text}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            print('❌ Error: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }

                          setState(() => _isSending = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Send Reset Link'),
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

       
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A192F), Color(0xFF112240), Color(0xFF1B2A41)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

       
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: Lottie.network(
              "https://assets9.lottiefiles.com/packages/lf20_qmfs6c3i.json",
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ),

        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ✅ Lottie above login box
                  Lottie.network(
                    'https://assets2.lottiefiles.com/packages/lf20_tno6cg2w.json',
                    height: 160,
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Glad to see you again!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

             
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Column(
                            children: [

                              _buildInputField(
                                controller: _emailController,
                                hint: 'Enter Email',
                                icon: Icons.email_outlined,
                                isPassword: false,
                              ),

                              const SizedBox(height: 16),

                              _buildInputField(
                                controller: _passwordController,
                                hint: 'Enter Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _forgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.cyanAccent),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                      
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 14),

                       
                              OutlinedButton(
                                onPressed: _skipLogin,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  side: const BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Continue as Guest",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                  GestureDetector(
                                    onTap: _goToSignUp,
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyanAccent,
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required bool isPassword,
}) {
  return TextField(
    controller: controller,
    keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
    enabled: !_isLoading,
    obscureText: isPassword ? !_isPasswordVisible : false,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      suffixIcon: isPassword
          ? IconButton(
              splashRadius: 20,
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 1.4),
      ),
    ),
  );
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
