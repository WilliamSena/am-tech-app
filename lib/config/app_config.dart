enum Environment { dev, prod }

class AppConfig {
  static late Environment _env;

  static void setEnvironment(Environment env) {
    _env = env;
  }

  static String get baseUrl {
    switch (_env) {
      case Environment.dev:
        return "URL_TESTE";
      case Environment.prod:
        return "URL_PROD";
    }
  }

  static bool get isProd => _env == Environment.prod;
}