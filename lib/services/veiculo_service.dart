import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo_model.dart';

class VeiculoService {
  final _collection = FirebaseFirestore.instance.collection('veiculos');

  Future<String> criar(Veiculo veiculo) async {
    var doc = await _collection.add(veiculo.toMap());
    return doc.id;
  }

  Stream<List<Veiculo>> listarPorCliente(String clienteId) {
    return _collection.where('idCliente', isEqualTo: clienteId).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();

          return Veiculo(
            id: doc.id,
            tipo: data['tipo'],
            marca: data['marca'],
            modelo: data['modelo'],
            placa: data['placa'],
            cor: data['cor'],
            dataInstalacao: data['dataInstalacao'],
            diaPagamento: data['diaPagamento'],
            valor: data['valor'],
            idCliente: data['idCliente'],
            status: data['status'],
          );
        }).toList();
      },
    );
  }

  Stream<List<Veiculo>> listarTodos() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Veiculo.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<Veiculo>> buscarPorIds(List<String> ids) async {
    List<Veiculo> lista = [];

    for (var id in ids) {
      var doc = await _collection.doc(id).get();

      if (doc.exists) {
        lista.add(Veiculo.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      }
    }

    return lista;
  }

  Future<String> buscarValor(String id) async {
    final doc = await _collection.doc(id).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['valor']?.toString() ?? '';
    }

    return '';
  }

  Future<void> atualizar(Veiculo v) async {
    await _collection.doc(v.id).update({
      'tipo': v.tipo,
      'marca': v.marca,
      'modelo': v.modelo,
      'placa': v.placa,
      'status': v.status,
      'diaPagamento': v.diaPagamento,
      'cor': v.cor,
      'valor': v.valor,
    });
  }

  Future<void> excluir(String id) async {
    await _collection.doc(id).update({'status': false});
  }
}
