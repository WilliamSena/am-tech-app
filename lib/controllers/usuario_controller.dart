import '../services/usuario_service.dart';
import '../models/usuario_model.dart';

class UsuarioController {
  final _service = UsuarioService();

  Future<Usuario?> login(String login, String senha) async {
    return await _service.login(login, senha);
  }
}