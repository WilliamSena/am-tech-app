import '../models/veiculo_model.dart';
import '../services/veiculo_service.dart';

class VeiculoController {
  final _service = VeiculoService();

  Future<String> criar(Veiculo veiculo) async {
    return await _service.criar(veiculo);
  }

  Future<void> atualizar(Veiculo veiculo) async {
    await _service.atualizar(veiculo);
  }

  Future<void> excluir(String id) async {
    await _service.excluir(id);
  }

  Stream<List<Veiculo>> listarPorCliente(String clienteId) {
    return _service.listarPorCliente(clienteId);
  }

  Stream<List<Veiculo>> listarTodos() {
    return _service.listarTodos();
  }

  Future<List<Veiculo>> buscarPorIds(List<String> ids) async {
    return await _service.buscarPorIds(ids);
  }
}
