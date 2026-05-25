import 'package:am_tech/services/version_utils.dart';
import 'package:am_tech/views/tela_inicial_view.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/usuario_controller.dart';
//import '../controllers/auth_controller.dart';
import '../services/session_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:am_tech/services/app_config_service.dart';
import 'package:am_tech/services/apk_update_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final loginController = TextEditingController();
  final senhaController = TextEditingController();
  final controller = UsuarioController();

  final session = SessionService();

  final Color primaryColor = Color(0xFF66B5FF);
  final Color secondaryColor = Color(0xFF3482F7);
  final Color bgColor = Color(0xFFF5F7FA);

  double progressoDownload = 0.0;
  bool baixando = false;
  bool instalando = false;

  @override
  void initState() {
    print("INCIO");
    super.initState();
    verificarAtualizacao();
  }

  Future<void> verificarAtualizacao() async {
    final config = await AppConfigService().buscarConfig();

    if (config == null) return;
    print("não é nulo");

    final info = await PackageInfo.fromPlatform();
    String versaoAtual = info.version;

    String versaoMinima = config['versao_minima'];
    String url = config['url_download'];
    bool bloquear = config['bloquear'];

    int resultado = VersionUtils.compare(versaoAtual, versaoMinima);
    print("VA: {$versaoAtual}\nVM: {$versaoMinima}\nRES: {$resultado}");

    if (resultado < 0) {
      mostrarDialogAtualizacao(url, bloquear);
    }
  }

  void mostrarDialogAtualizacao(String url, bool bloquear) {
    showDialog(
      context: context,
      barrierDismissible: !bloquear,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Atualização necessária"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bloquear
                        ? "Você precisa atualizar o app para continuar."
                        : "Uma nova versão está disponível.",
                  ),

                  SizedBox(height: 20),

                  // 🔥 BARRA DE DOWNLOAD
                  if (baixando)
                    Column(
                      children: [
                        LinearProgressIndicator(value: progressoDownload),
                        SizedBox(height: 10),
                        Text(
                          "Baixando ${(progressoDownload * 100).toStringAsFixed(0)}%",
                        ),
                      ],
                    ),

                  // 🔥 INSTALAÇÃO (simulada)
                  if (instalando)
                    Column(
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Abrindo instalador..."),
                      ],
                    ),
                ],
              ),

              actions: [
                if (!bloquear && !baixando)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Depois"),
                  ),

                // 🔥 BOTÃO INTELIGENTE
                ElevatedButton(
                  onPressed: baixando
                      ? null
                      : () async {
                          setState(() => baixando = true);
                          setStateDialog(() {});

                          await ApkUpdateService().baixarEInstalar(url, (
                            progress,
                          ) {
                            setState(() {
                              progressoDownload = progress;
                            });
                            setStateDialog(() {});
                          });

                          // 🔥 terminou download
                          setState(() {
                            baixando = false;
                            instalando = true;
                          });
                          setStateDialog(() {});
                        },

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    backgroundColor: baixando
                        ? Colors.grey
                        : primaryColor,
                        foregroundColor: Colors.white,
                  ),

                  child: baixando
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "${(progressoDownload * 100).toStringAsFixed(0)}%",
                            ),
                          ],
                        )
                      : instalando
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Instalando..."),
                          ],
                        )
                      : Text("Atualizar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void iniciarDownload(String url, Function setStateDialog) async {
    setState(() {
      baixando = true;
      progressoDownload = 0.0;
    });

    await ApkUpdateService().baixarEInstalar(url, (progress) {
      setState(() {
        progressoDownload = progress;
      });

      // 🔥 ATUALIZA O DIALOG
      setStateDialog(() {});
    });

    setState(() {
      baixando = false;
    });

    setStateDialog(() {});
  }

  void login() async {
    try {
      if (loginController.text.isEmpty || senhaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preencha login e senha'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      var user = await controller.login(
        loginController.text,
        senhaController.text,
      );

      if (user != null) {
        // ✅ SUCESSO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        //await session.salvarSessao(user.login, user.acesso);

        // pequena pausa pra mostrar a mensagem
        await Future.delayed(Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaInicialView()),
        );
      } else {
        // ❌ LOGIN INVÁLIDO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário ou senha inválidos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // 💥 ERRO REAL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔝 HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium(context),
                80,
                AppSpacing.medium(context),
                40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // 👉 SUA LOGO AQUI (se quiser)
                  Image.asset(
                    'assets/logo-horizontal.png',
                    height: width * 0.2,
                  ),
                  SizedBox(height: AppSpacing.small(context)),
                  Text(
                    'Bem-vindo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.large(context)),

            // 🧊 CARD LOGIN
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium(context),
              ),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.medium(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 👤 LOGIN
                    TextField(
                      controller: loginController,
                      decoration: InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.medium(context)),

                    // 🔒 SENHA
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.large(context)),

                    // 🚀 BOTÃO
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.medium(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: login,
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
