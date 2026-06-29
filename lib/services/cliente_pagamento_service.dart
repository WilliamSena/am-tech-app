import 'package:am_tech/controllers/veiculo_controller.dart';
import 'package:am_tech/models/cliente_pagamento_model.dart';
import 'package:am_tech/services/veiculo_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientePagamentoService {
  final _ref = FirebaseFirestore.instance.collection('cliente_pagamento');

  Future<void> criar(ClientePagamento pagamento) async {
    await _ref.add(pagamento.toMap());
  }

  Future<void> atualizar(ClientePagamento pagamento) async {
    await _ref.doc(pagamento.id).update(pagamento.toMap());
  }

  Stream<List<ClientePagamento>> listarPorCliente(String idCliente) {
    return _ref
        .where('idCliente', isEqualTo: idCliente)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return ClientePagamento.fromMap(doc.data(), doc.id);
          }).toList(),
        );
  }

  Stream<List<ClientePagamento>> listarTodos() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClientePagamento.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<bool> existeBoleto({
    required String idCliente,
    required DateTime vencimento,
    required List<String> idsVeiculos,
  }) async {
    var snapshot = await _ref
        .where('idCliente', isEqualTo: idCliente)
        .where('dataVencimento', isEqualTo: vencimento)
        .get();

    if (snapshot.docs.isEmpty) return false;

    // 🔥 verifica se já existe com os mesmos veículos
    for (var doc in snapshot.docs) {
      List ids = doc['idsVeiculos'];

      if (ids.length == idsVeiculos.length &&
          ids.toSet().containsAll(idsVeiculos)) {
        return true;
      }
    }

    return false;
  }

  Future<void> atualizarVeiculoExcluidoBoletoAberto({required String idCliente}) async{
    try {
      final boletos = await _ref
          .where('idCliente', isEqualTo: idCliente)
          .where('status', isEqualTo: 'PENDENTE')
          .get();

      if (boletos.docs.isEmpty) {
        //return 'Nenhum boleto encontrado';
      }

      double valor = await VeiculoController().atualizarValorPorVeiculoAtivo(idCliente);

      for (var doc in boletos.docs) {
        final dados = doc.data();

        await doc.reference.update({
          'valorPagar': valor,
        });
      }

    } catch (e) {
      
    }
  }

  Future<String> atualizarDiaPagamentoBoletoAberto({
    required String idCliente,
    required String novoDiaPagamento,
  }) async {
    try {
      final boletos = await _ref
          .where('idCliente', isEqualTo: idCliente)
          .where('status', isEqualTo: 'PENDENTE')
          .get();

      if (boletos.docs.isEmpty) {
        return 'Nenhum boleto encontrado';
      }

      int atualizados = 0;

      for (var doc in boletos.docs) {
        final dados = doc.data();
        final DateTime dataAtual = (dados['dataVencimento'] as Timestamp)
            .toDate();

        final novaData = DateTime(
          dataAtual.year,
          dataAtual.month,
          int.parse(novoDiaPagamento),
        );

        final veiculos = dados['idsVeiculos'];
        double total = 0;
        final veiculoService = VeiculoService();

        for (String id in veiculos) {
          final valor = await veiculoService.buscarValor(id);
          total += double.tryParse(valor) ?? 0;
        }

        await doc.reference.update({
          'dataVencimento': Timestamp.fromDate(novaData),
          'valorPagar': total,
        });

        atualizados++;
      }

      return 'Dados atualizados com sucesso!';
    } catch (e) {
      return 'ERRO: $e';
    }
  }
}
