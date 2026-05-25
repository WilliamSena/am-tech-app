import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';

class ClienteService {
  final CollectionReference _clientes = FirebaseFirestore.instance.collection(
    'clientes',
  );

  Future<String> criar(Cliente cliente) async {
    var doc = await _clientes.add(cliente.toMap());
    return doc.id; // 🔥 retorna ID real
  }

  Stream<List<Cliente>> listarTodos() {
    return _clientes.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Cliente>> listarAtivos() {
    return _clientes.where('status', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      var clientes = snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // 🔥 ORDENA ALFABETICAMENTE
      clientes.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

      return clientes;
    });
  }

  Stream<List<Cliente>> buscarPorNome(String nome) {
    return _clientes
        .where('nome', isGreaterThanOrEqualTo: nome)
        .where('nome', isLessThanOrEqualTo: '$nome\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  Future<Cliente?> buscarPorId(String id) async {
    var doc = await _clientes.doc(id).get();

    if (!doc.exists || doc.data() == null) return null;

    return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> atualizar(Cliente cliente) async {
    await _clientes.doc(cliente.id).update({
      'nome': cliente.nome,
      'cpf': cliente.cpf,
      'email': cliente.email,
      'status': cliente.status,
    });
  }

  Future<void> excluir(String id) async {
    await _clientes.doc(id).update({'status': false});
  }

  Future<void> deletar(String id) async {
    await _clientes.doc(id).delete();
  }
}
