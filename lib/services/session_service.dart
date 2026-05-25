import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyLogin = 'user_login';
  static const _keyAcesso = 'user_acesso';

  Future<void> salvarSessao(String login, String acesso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogin, login);
    await prefs.setString(_keyAcesso, acesso);
  }

  Future<Map<String, String>?> getSessao() async {
    final prefs = await SharedPreferences.getInstance();

    final login = prefs.getString(_keyLogin);
    final acesso = prefs.getString(_keyAcesso);

    if (login == null) return null;

    return {
      'login': login,
      'acesso': acesso ?? '',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}