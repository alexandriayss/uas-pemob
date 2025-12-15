import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/mortava_theme.dart';
import 'login_page.dart';
import 'marketplace_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    // Tahan 3 detik
    await Future.delayed(const Duration(seconds: 3));

    // Cek apakah sudah login
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (!mounted) return;

    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MarketplacePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: MortavaDecorations.marketplaceBackgroundBox(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo mortava
              SizedBox(
                height: 130,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // app name
              Text(
                "Mortava Shop",
                style: MortavaTextStyles.headingLarge(),
              ),

              const SizedBox(height: 6),

              Text(
                "Marketplace made simple.",
                style: MortavaTextStyles.bodySmall(),
              ),

              const SizedBox(height: 32),

              // loading circle
              const CircularProgressIndicator(
                color: Color(0xFFFF7043),
                strokeWidth: 2.5,
              )
            ],
          ),
        ),
      ),
    );
  }
}