import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  Future<String> getVersao() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<String> getBuild() async {
    final info = await PackageInfo.fromPlatform();
    return info.buildNumber;
  }

  Future<String> getVersaoCompleta() async {
    final info = await PackageInfo.fromPlatform();
    return "${info.version}+${info.buildNumber}";
  }
}
