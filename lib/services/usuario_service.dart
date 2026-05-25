import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  final _fire = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
  );
  //final _collection = FirebaseFirestore.instance.collection('usuarios');

  /*Future<Usuario?> login(String login, String senha) async {
    var result = await _collection
        .where('login', isEqualTo: login)
        .where('senha', isEqualTo: senha)
        .where('status', isEqualTo: true)
        .get();

    if (result.docs.isEmpty) return null;

    var doc = result.docs.first;

    return Usuario.fromMap(
      doc.data(),
      doc.id,
    );
  }*/

  Future<Usuario?> login(String login, String senha) async {
    final collection = _fire.collection('usuarios');
    var result = await collection
        .where('login', isEqualTo: login)
        .where('status', isEqualTo: true)
        .get();

    if (result.docs.isEmpty) return null;

    var doc = result.docs.first;
    var usuario = Usuario.fromMap(doc.data(), doc.id);

    // 🔥 comparar senha (exemplo simples)
    if (usuario.senha != senha) return null;

    return usuario;
  }
}
