//Service: baca data user dari SharedPreferences, menghapus data saat logout
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('user_id');
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    if (id == null || username == null || email == null) {
      return null;
    }

    return UserModel(
      id: id,
      username: username,
      email: email,
      // contoh dummy sementara:
      createdAt: '02 Desember 2025',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
