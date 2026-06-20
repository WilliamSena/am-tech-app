import 'package:am_tech/controllers/cliente_pagamento_controller.dart';

import '../models/veiculo_model.dart';
import '../services/veiculo_service.dart';

class VeiculoController {
  final _service = VeiculoService();
  final controllerClientePagamento = ClientePagamentoController();

  Future<String> criar(Veiculo veiculo) async {
    return await _service.criar(veiculo);
  }

  Future<String> atualizar(Veiculo veiculo) async {
    String msg = '';
    
    await _service.atualizar(veiculo);
    msg = await controllerClientePagamento.atualizarDiaPagamentoBoleto(
      veiculo.idCliente,
      veiculo.diaPagamento,
    );

    return msg;
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
