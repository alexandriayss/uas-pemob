import '../services/auth_service.dart';

class AuthController {
  final AuthService _service = AuthService();

  // return null = login sukses, return String = pesan error untuk UI
  Future<String?> login(String email, String password) async {
    // Validasi input kosong
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    // Validasi format email dasar
    final emailRegex =
        RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    try {
      await _service.login(
        identifier: email, 
        password: password,
      );

      // sukses
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();

      // salah password / email
      if (msg.contains('401') ||
          msg.contains('unauthorized') ||
          msg.contains('invalid')) {
        return 'Incorrect email or password';
      }

      //  user tidak ditemukan
      if (msg.contains('not found') ||
          msg.contains('user')) {
        return 'Account not found';
      }

      // tidak ada koneksi internet
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('timeout')) {
        return 'No internet connection';
      }

      // error lain
      return 'Incorrect email or password';
    }
  }
}
