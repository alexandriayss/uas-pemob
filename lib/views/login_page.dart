import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../theme/mortava_theme.dart';
import 'marketplace_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();

  final AuthController _authController = AuthController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Menyimpan pesan error agar tampil di dalam UI (tanpa Snackbar)
  String? _errorMessage;

  // Fungsi login 
  Future<void> _login() async {
    final identifier = _identifierC.text.trim();
    final password = _passwordC.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // reset error setiap login
    });

    final error = await _authController.login(identifier, password);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error; // tampilkan error di UI
        _isLoading = false;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MarketplacePage()),
    );
  }

  @override
  void dispose() {
    _identifierC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND UTAMA
      body: Container(
        decoration: MortavaDecorations.authBackgroundBox(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card login
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: MortavaDecorations.authCardBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo aplikasi
                        SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Judul sambutan
                        Text(
                          'Welcome back 👋',
                          style: MortavaTextStyles.headingLarge(),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Sign in to your Mortava Shop account\nand continue your shopping journey.',
                          textAlign: TextAlign.center,
                          style: MortavaTextStyles.bodySmall(),
                        ),

                        const SizedBox(height: 28),

                        // Label Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email address',
                            style: MortavaTextStyles.labelSmall(),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Input Email
                        TextField(
                          controller: _identifierC,

                          // Keyboard email
                          keyboardType: TextInputType.emailAddress,

                          decoration: MortavaInputs.roundedInput(
                            hint: 'you@example.com',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),

                        const SizedBox(height: 18),

                        // Label Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: MortavaTextStyles.labelSmall(),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Input Password
                        TextField(
                          controller: _passwordC,
                          obscureText: _obscurePassword,
                          decoration: MortavaInputs.roundedInput(
                            hint: 'Enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
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
                        ),

                        const SizedBox(height: 14),

                        // Tampilkan pesan error jika ada
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 22),

                        // Tombol SIGN IN
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
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
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        'SIGN IN',
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

                  const SizedBox(height: 18),

                  // Navigasi ke halaman register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign up',
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