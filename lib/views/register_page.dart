import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../theme/mortava_theme.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();
  final TextEditingController _confirmC = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameC.text.trim();
    final email = _emailC.text.trim();
    final password = _passwordC.text;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = Uri.parse('http://mortava.biz.id/api/register');

      final response = await http.post(
        url,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;

      final dynamic raw = jsonDecode(response.body);

      String message = 'Registration failed (${response.statusCode})';
      int? userId;

      if (raw is Map<String, dynamic>) {
        if (raw['message'] != null) {
          message = raw['message'].toString();
        }
        if (raw['userID'] != null) {
          userId = raw['userID'] as int;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('User registered with id: $userId');

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MortavaDecorations.authBackgroundBox(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // card register
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: MortavaDecorations.registerCardBox(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo aplikasi
                          SizedBox(
                            height: 100,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Judul
                          Text(
                            'Create your account ✨',
                            style: MortavaTextStyles.headingMedium(),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'Join Mortava Shop and start your\nshopping journey with us.',
                            textAlign: TextAlign.center,
                            style: MortavaTextStyles.bodySmall(),
                          ),

                          const SizedBox(height: 24),

                          // Username
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: MortavaTextStyles.labelSmall(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameC,
                            decoration: MortavaInputs.roundedInput(
                              hint: 'Choose a unique username',
                              prefixIcon: const Icon(
                                  Icons.person_outline, size: 20),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Username is required'
                                    : null,
                          ),

                          const SizedBox(height: 16),

                          // Email
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email address',
                              style: MortavaTextStyles.labelSmall(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailC,
                            decoration: MortavaInputs.roundedInput(
                              hint: 'you@example.com',
                              prefixIcon: const Icon(
                                  Icons.email_outlined, size: 20),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password',
                              style: MortavaTextStyles.labelSmall(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordC,
                            obscureText: _obscurePassword,
                            decoration: MortavaInputs.roundedInput(
                              hint: 'Create a strong password',
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Confirm password',
                              style: MortavaTextStyles.labelSmall(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmC,
                            obscureText: _obscureConfirm,
                            decoration: MortavaInputs.roundedInput(
                              hint: 'Re-enter your password',
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _passwordC.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Tombol SIGN UP
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _register,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: const StadiumBorder(),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: MortavaGradients.primaryButton,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'SIGN UP',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            color: MortavaColors.darkText,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Navigasi kembali ke halaman login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
    );
  }
}
