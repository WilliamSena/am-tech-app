import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteController {
  final ClienteService _service = ClienteService();

  Future<String> criar(Cliente cliente) async {
    return await _service.criar(cliente);
  }

  Stream<List<Cliente>> listar() {
    return _service.listarAtivos();
  }

  Stream<List<Cliente>> listarTodos() {
    return _service.listarTodos();
  }

  Future<void> atualizar(Cliente cliente) async {
    await _service.atualizar(cliente);
  }

  Future<void> excluir(String id) async {
    await _service.excluir(id);
  }

  Future<Cliente?> buscarPorId(String id) async{
    return await _service.buscarPorId(id);
  }
}
