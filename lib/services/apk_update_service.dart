import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ApkUpdateService {
  final Dio dio = Dio();

  Future<void> baixarEInstalar(String url, Function(double) onProgress) async {
    try {
      print("Entrou no try");
      final dir = await getExternalStorageDirectory();
      final path = "${dir!.path}/update.apk";

      await dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progresso = received / total;
            print("📊 Progresso: ${(progresso * 100).toStringAsFixed(0)}%");
            onProgress(progresso);
          }
        },
      );

      /*print("Até aqui ok");

      File file = File(path);
      int size = await file.length();

      print("📦 TAMANHO APK: $size bytes");

      if (await file.exists()) {
        print("✅ APK EXISTE: $path");
      } else {
        print("❌ APK NÃO EXISTE");
        return;
      }*/

      // 🔥 abre instalador
      await OpenFilex.open(path);

    } catch (e) {
      print("💥 ERRO DOWNLOAD: $e");
    }
  }
}
