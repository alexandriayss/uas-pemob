// lib/controllers/auth_controller.dart
import '../services/auth_service.dart';

class AuthController {
  final AuthService _service = AuthService();

  /// return null = sukses
  /// return String = pesan error
  Future<String?> login(String identifier, String password) async {
    if (identifier.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    try {
      await _service.login(
        identifier: identifier,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
