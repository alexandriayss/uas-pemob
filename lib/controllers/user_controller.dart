import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController {
  final UserService _service = UserService();

  Future<UserModel?> getCurrentUser() {
    return _service.getCurrentUser();
  }

  Future<void> logout() {
    return _service.logout();
  }
}
