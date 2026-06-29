import 'package:am_tech/controllers/veiculo_controller.dart';

import '../models/cliente_pagamento_model.dart';
import '../services/cliente_pagamento_service.dart';

class ClientePagamentoController {
  final service = ClientePagamentoService();

  Future<void> criar(ClientePagamento p) => service.criar(p);

  Future<void> atualizar(ClientePagamento p) => service.atualizar(p);

  Stream<List<ClientePagamento>> listarPorCliente(String idCliente) {
    return service.listarPorCliente(idCliente);
  }

  Stream<List<ClientePagamento>> listarTodos() {
    return service.listarTodos();
  }

  Future<void> gerarProximo(ClientePagamento atual) async {
    final controller = ClientePagamentoController();
    double valor = await VeiculoController().atualizarValorPorVeiculoAtivo(atual.idCliente);

    DateTime novoVencimento = DateTime(
      atual.dataVencimento.year,
      atual.dataVencimento.month + 1,
      atual.dataVencimento.day,
    );

    var novo = ClientePagamento(
      idCliente: atual.idCliente,
      idsVeiculos: atual.idsVeiculos,
      dataVencimento: novoVencimento,
      valorPagar: valor,
      valorRecebido: 0,
      status: 'PENDENTE',
    );

    await controller.criar(novo);
  }

  Future<String> atualizarDiaPagamentoBoleto(
    String idCliente,
    String novoDiaPagamento,
  ) async {
    return service.atualizarDiaPagamentoBoletoAberto(
      idCliente: idCliente,
      novoDiaPagamento: novoDiaPagamento,
    );
  }

  Future<void> atualizarVeiculoExcluidoBoletoAberto( String idCliente) async{
    service.atualizarVeiculoExcluidoBoletoAberto(idCliente: idCliente);
 }}
