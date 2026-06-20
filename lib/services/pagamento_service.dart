import 'package:am_tech/services/cliente_pagamento_service.dart';

import '../controllers/cliente_pagamento_controller.dart';
import '../models/veiculo_model.dart';
import '../models/cliente_pagamento_model.dart';

Future<void> gerarBoletosInicial(
  String idCliente,
  List<Veiculo> veiculos,
) async {
  final controller = ClientePagamentoController();
  final service = ClientePagamentoService();

  Map<String, List<Veiculo>> grupos = {};

  for (var v in veiculos) {
    grupos.putIfAbsent(v.diaPagamento, () => []).add(v);
  }

  for (var grupo in grupos.entries) {
    var lista = grupo.value;

    double total = 0;

    for (var v in lista) {
      total += double.tryParse(v.valor ?? '0') ?? 0;
    }

    DateTime hoje = DateTime.now();

    DateTime vencimento = DateTime(
      hoje.year,
      hoje.month + 1,
      int.tryParse(grupo.key) ?? 1,
    );

    List<String> idsVeiculos = lista.map((v) => v.id!).toList();

    // 🔥 🔥 VALIDAÇÃO AQUI
    bool jaExiste = await service.existeBoleto(
      idCliente: idCliente,
      vencimento: vencimento,
      idsVeiculos: idsVeiculos,
    );

    if (jaExiste) {
      print('⚠️ Boleto já existe, ignorando...');
      continue;
    }

    var pagamento = ClientePagamento(
      idCliente: idCliente,
      idsVeiculos: idsVeiculos,
      dataVencimento: vencimento,
      valorPagar: total,
      valorRecebido: 0,
      status: 'PENDENTE',
    );

    await controller.criar(pagamento);
  }
}

Future<void> atualizarStatusBoletos(List<ClientePagamento> lista) async {
  final controller = ClientePagamentoController();

  DateTime hoje = DateTime.now();

  for (var p in lista) {
    String novoStatus;

    if (p.dataPagamentoRealizado != null) {
      novoStatus = 'PAGO';
    } else if (p.dataVencimento.isBefore(hoje) &&
        p.dataPagamentoRealizado == null) {
      novoStatus = 'ATRASADO';

      if (p.status != 'ATRASADO') {
        await gerarProximoBoleto(p);
      }
    } else {
      novoStatus = 'PENDENTE';
    }

    if (p.status != novoStatus) {
      p.status = novoStatus;
      await controller.atualizar(p);
    }
  }
}

Future<void> gerarProximoBoleto(ClientePagamento atual) async {
  final controller = ClientePagamentoController();
  final service = ClientePagamentoService();

  // 🔥 próximo mês
  DateTime proximoVencimento = DateTime(
    atual.dataVencimento.year,
    atual.dataVencimento.month + 1,
    atual.dataVencimento.day,
  );

  // 🔥 verificar duplicação
  bool jaExiste = await service.existeBoleto(
    idCliente: atual.idCliente,
    vencimento: proximoVencimento,
    idsVeiculos: atual.idsVeiculos,
  );

  if (jaExiste) {
    print('⚠️ Próximo boleto já existe');
    return;
  }

  var novo = ClientePagamento(
    idCliente: atual.idCliente,
    idsVeiculos: atual.idsVeiculos,
    dataVencimento: proximoVencimento,
    valorPagar: atual.valorPagar,
    valorRecebido: 0,
    status: 'PENDENTE',
  );

  await controller.criar(novo);
}
