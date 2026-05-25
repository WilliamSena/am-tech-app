import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    verificarSessao();
  }

  void verificarSessao() async {
    try {
      await FirebaseFirestore.instance
        .collection('teste')
        .add({'ok': true});

    print("🔥 FIREBASE OK");
      final session = SessionService();
      //final user = await session.getSessao();

      print("Sessão OK");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
      );
    } catch (e) {
      print("ERRO: $e");
    }
  }

  /*void verificarSessao() async {
    final session = SessionService();
    final user = await session.getSessao();

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResumoView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
