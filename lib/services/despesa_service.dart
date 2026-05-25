import 'package:am_tech/models/despesa_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DespesaService {
  final CollectionReference _service = FirebaseFirestore.instance.collection(
    'despesas',
  );

  Future<String> criar(Despesa despesa) async {
    var doc = await _service.add(despesa.toMap());
    return doc.id;
  }

  Stream<List<Despesa>> listarDespesas() {
    return _service
        .orderBy('dataRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Despesa.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Despesa>> listar() {
    return _service.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Despesa.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  
}
