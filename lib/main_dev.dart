import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setEnvironment(Environment.dev);

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); // 🔥 obrigatório
  /*await Firebase.initializeApp(
    options: AppConfig.isProd
        ? DefaultFirebaseOptions.prod
        : DefaultFirebaseOptions.dev,
  );*/

  runApp(const MyApp());
}
