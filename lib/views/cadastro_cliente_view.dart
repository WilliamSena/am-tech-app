import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente_model.dart';
import '../views/cadastro_veiculo_view.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroClienteView extends StatefulWidget {
  final Cliente? cliente;

  const CadastroClienteView({super.key, this.cliente});

  @override
  _CadastroClienteViewState createState() => _CadastroClienteViewState();
}

class _CadastroClienteViewState extends State<CadastroClienteView> {
  final controller = ClienteController();

  final nome = TextEditingController();
  final cpf = TextEditingController();
  final email = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // 🔥 VALIDAÇÃO

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final Color primaryColor = Color(0xFF1E88E5);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();

    // 👉 AQUI é onde entra o ponto 2
    if (widget.cliente != null) {
      nome.text = widget.cliente!.nome;
      cpf.text = widget.cliente!.cpf;
      email.text = widget.cliente!.email;
    }
  }

  void salvar() async {
    // 🔥 VALIDA FORM
    if (!_formKey.currentState!.validate()) return;

    var cliente = Cliente(
      id: widget.cliente?.id,
      nome: nome.text,
      cpf: cpf.text,
      email: email.text,
      status: true,
    );

    if (widget.cliente == null) {
      // 🔥 CRIA E PEGA O ID
      String clienteId = await controller.criar(cliente);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CadastroVeiculoView(
            nomeCliente: cliente.nome,
            idCliente: clienteId,
          ),
        ),
      );
    } else {
      // ✏️ EDIÇÃO NORMAL
      await controller.atualizar(cliente);

      Navigator.pop(context);
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
                60,
                AppSpacing.medium(context),
                30,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: AppSpacing.medium(context)),
                  Text(
                    widget.cliente == null
                        ? "Novo Cliente"
                        : "Editar Cliente",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔽 SOBREPOSIÇÃO (igual outras telas)
            Transform.translate(
              offset: Offset(0, -AppSpacing.large(context)),
              child: Padding(
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
                      )
                    ],
                  ),

                  // 🔥 FORM
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 👤 NOME
                        TextFormField(
                          controller: nome,
                          decoration: InputDecoration(
                            labelText: 'Nome *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: AppSpacing.medium(context)),

                        // 🆔 CPF
                        TextFormField(
                          controller: cpf,
                          inputFormatters: [cpfMask],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CPF *',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CPF é obrigatório';
                            }
                            if (value.length < 14) {
                              return 'CPF inválido';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: AppSpacing.medium(context)),

                        // 📧 EMAIL (opcional)
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
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
                                vertical:
                                    AppSpacing.medium(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: salvar,
                            child: Text(
                              'Salvar',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
