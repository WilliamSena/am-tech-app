import 'package:am_tech/models/cliente_pagamento_model.dart';
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
}
