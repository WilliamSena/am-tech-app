import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthService _service = AuthService();

  Future<UserModel?> login(String email, String senha) async {
    return await _service.login(email, senha);
  }

  Future<UserModel?> register(String email, String senha) async {
    return await _service.register(email, senha);
  }

  Future<void> logout() async {
    await _service.logout();
  }
}