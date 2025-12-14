// lib/controllers/auth_controller.dart
import '../services/auth_service.dart';

class AuthController {
  final AuthService _service = AuthService();

  /// return null = login sukses
  /// return String = pesan error untuk UI
  Future<String?> login(String email, String password) async {
    // 🔥 VALIDASI KOSONG
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    // 🔥 VALIDASI EMAIL SAJA (WAJIB EMAIL)
    final emailRegex =
        RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    try {
      await _service.login(
        identifier: email, // tetap kirim ke backend
        password: password,
      );

      // ✅ sukses
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();

      // 🔥 SALAH EMAIL / PASSWORD
      if (msg.contains('401') ||
          msg.contains('unauthorized') ||
          msg.contains('invalid')) {
        return 'Incorrect email or password';
      }

      // 🔥 USER TIDAK DITEMUKAN
      if (msg.contains('not found') ||
          msg.contains('user')) {
        return 'Account not found';
      }

      // 🔥 INTERNET / SERVER
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('timeout')) {
        return 'No internet connection';
      }

      // 🔥 FALLBACK AMAN
      return 'Incorrect email or password';
    }
  }
}
