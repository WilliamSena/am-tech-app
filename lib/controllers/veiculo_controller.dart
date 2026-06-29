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

  Future<double> atualizarValorPorVeiculoAtivo(String idCliente) async{
    List<Veiculo> veiculos = await _service.listarPorClienteFuture(idCliente);
    double valor = 0;

    for(var v in veiculos){
      if(v.status){
        valor += double.tryParse(v.valor) ?? 0;
      }
    }

    return valor;
  }

  Future<void> excluir(String id) async {
    String idCliente = await _service.retornarIdCliente(id);
    await _service.excluir(id);
    controllerClientePagamento.atualizarVeiculoExcluidoBoletoAberto(idCliente);
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
