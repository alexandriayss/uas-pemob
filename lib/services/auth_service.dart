import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _api.postRaw(
        '/login',
        jsonEncode({'identifier': identifier, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('user_id', data['user']['id']);
        prefs.setString('username', data['user']['username']);
        prefs.setString('email', data['user']['email']);
        return;
      } else {
        String errorMsg = 'Login gagal (${response.statusCode})';

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            errorMsg = body['message'];
          }
        } catch (_) {}

        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
