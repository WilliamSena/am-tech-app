import 'package:am_tech/models/empresa_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmpresaService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('empresa');

  Stream<Empresa?> buscarPorCNPJ(String cnpj){
    return _collection.where('cnpj', isEqualTo: cnpj).limit(1).snapshots().map((snapshot){
      if(snapshot.docs.isEmpty) return null;

      var doc = snapshot.docs.first;

      return Empresa.fromMap(doc.data() as Map<String, dynamic>, doc.id,);
    });
  }
}