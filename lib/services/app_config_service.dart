import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfigService {
  final _ref =
      FirebaseFirestore.instance.collection('config_app').doc('versao');

  Future<Map<String, dynamic>?> buscarConfig() async {
    try {
      var doc = await _ref.get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print("💥 ERRO CONFIG: $e");
      return null;
    }
  }
}