import 'package:am_tech/controllers/cliente_controller.dart';
import 'package:am_tech/controllers/cliente_pagamento_controller.dart';
import 'package:am_tech/models/cliente_model.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/veiculo_controller.dart';
import '../models/veiculo_model.dart';
import '../services/pagamento_service.dart';

class CadastroVeiculoView extends StatefulWidget {
  final String? nomeCliente;
  final String? idCliente;
  final Veiculo? veiculo;

  const CadastroVeiculoView({
    super.key,
    this.nomeCliente,
    this.idCliente,
    this.veiculo,
  });

  @override
  _CadastroVeiculoViewState createState() => _CadastroVeiculoViewState();
}

class _CadastroVeiculoViewState extends State<CadastroVeiculoView> {
  final controller = VeiculoController();
  final controllerClientePagamento = ClientePagamentoController();
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = Color(0xFF1E88E5);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  final tipo = TextEditingController();
  final marca = TextEditingController();
  final modelo = TextEditingController();
  final placa = TextEditingController();
  final cor = TextEditingController();
  final dataInstalacao = TextEditingController();
  final diaPagamento = TextEditingController();
  final valor = TextEditingController();

  String? clienteSelecionadoId;
  String? clienteSelecionadoNome;
  List<VeiculoForm> veiculos = [VeiculoForm()];

  @override
  void initState() {
    super.initState();

    clienteSelecionadoId = widget.idCliente;
    clienteSelecionadoNome = widget.nomeCliente;

    // 🔥 MODO EDIÇÃO
    if (widget.veiculo != null) {
      final v = widget.veiculo!;

      veiculos = [
        VeiculoForm()
          ..id = v.id
          ..tipo.text = v.tipo
          ..marca.text = v.marca
          ..modelo.text = v.modelo
          ..placa.text = v.placa
          ..cor.text = v.cor
          ..dataInstalacao.text = v.dataInstalacao
          ..diaPagamento.text = v.diaPagamento
          ..valor.text = v.valor,
      ];
    }
  }

  void salvarTodos() async {
    if (!_formKey.currentState!.validate()) return;

    if (clienteSelecionadoId == null || clienteSelecionadoId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selecione um cliente')));
      return;
    }

    List<Veiculo> veiculosSalvos = [];
    String msg = "";

    for (var v in veiculos) {
      var veiculo = Veiculo(
        id: v.id, // 🔥 IMPORTANTE
        tipo: v.tipo.text,
        marca: v.marca.text,
        modelo: v.modelo.text,
        placa: v.placa.text,
        cor: v.cor.text,
        dataInstalacao: v.dataInstalacao.text,
        diaPagamento: v.diaPagamento.text,
        valor: v.valor.text,
        idCliente: clienteSelecionadoId!,
        status: true,
      );

      if (v.id == null) {
        // 🟢 NOVO
        var idGerado = await controller.criar(veiculo);

        veiculo.id = idGerado;
        veiculosSalvos.add(veiculo);

        msg = 'Veículos salvos com sucesso!';
      } else {
        // 🔵 EDITAR
        // guarda o dia antigo antes de atualizar
        //String diaPagamentoAntigo = widget.veiculo?.diaPagamento ?? '';

        // atualiza o cadastro do veículo
        clienteSelecionadoId = veiculo.idCliente;
        msg = await controller.atualizar(veiculo);

        // verifica se o dia do pagamento mudou
        /*print('ID VEICULO: ${v.id}');
        print('Dia ant: $diaPagamentoAntigo \nDia nov: ');
        if (diaPagamentoAntigo != v.diaPagamento.text) {
          // atualiza o boleto em aberto do cliente
          await controllerClientePagamento.atualizarDiaPagamentoBoleto(
            clienteSelecionadoId!,
            v.diaPagamento.text
          );
        }*/
      }
    }

    if (widget.veiculo == null) {
      await gerarBoletosInicial(clienteSelecionadoId!, veiculosSalvos);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));

    Navigator.pop(context);
  }

  void adicionarVeiculo() {
    setState(() {
      veiculos.add(VeiculoForm());
    });
  }

  void editarVeiculo(VeiculoForm v) {
    setState(() {
      veiculos = [
        VeiculoForm()
          ..id = v.id
          ..tipo.text = v.tipo.text
          ..marca.text = v.marca.text
          ..modelo.text = v.modelo.text
          ..placa.text = v.placa.text
          ..cor.text = v.cor.text
          ..dataInstalacao = v.dataInstalacao
          ..diaPagamento = v.diaPagamento
          ..valor = v.valor,
      ];
    });
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
                    "Cadastro de Veículos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

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
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),

                  // 🔥 FORM GLOBAL
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 👤 CLIENTE
                        if (widget.idCliente != null)
                          Text(
                            clienteSelecionadoNome ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        else
                          StreamBuilder<List<Cliente>>(
                            stream: ClienteController().listar(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Padding(
                                  padding: EdgeInsets.all(
                                    AppSpacing.small(context),
                                  ),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              var clientes = snapshot.data!;

                              return DropdownButtonFormField<String>(
                                initialValue: clienteSelecionadoId,
                                hint: Text('Selecione o cliente'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: clientes.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text(c.nome),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    clienteSelecionadoId = value;
                                    clienteSelecionadoNome = clientes
                                        .firstWhere((c) => c.id == value)
                                        .nome;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Selecione um cliente'
                                    : null,
                              );
                            },
                          ),

                        SizedBox(height: AppSpacing.medium(context)),

                        // 🚗 LISTA DE VEÍCULOS
                        ...veiculos.asMap().entries.map((entry) {
                          int index = entry.key;
                          var v = entry.value;

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: AppSpacing.medium(context),
                            ),
                            padding: EdgeInsets.all(AppSpacing.medium(context)),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Veículo ${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                campoObrigatorio(v.tipo, 'Tipo'),
                                campoObrigatorio(v.marca, 'Marca'),
                                campoObrigatorio(v.modelo, 'Modelo'),
                                campoObrigatorio(v.placa, 'Placa'),
                                campoObrigatorio(v.valor, 'Valor'),

                                DropdownButtonFormField<String>(
                                  initialValue: v.diaPagamento.text.isNotEmpty
                                      ? v.diaPagamento.text
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Dia do pagamento *',
                                  ),
                                  items: List.generate(31, (i) {
                                    String dia = '${i + 1}';
                                    return DropdownMenuItem(
                                      value: dia,
                                      child: Text(dia),
                                    );
                                  }),
                                  onChanged: (value) {
                                    v.diaPagamento.text = value!;
                                  },
                                  validator: (value) =>
                                      value == null ? 'Obrigatório' : null,
                                ),

                                if (veiculos.length > 1)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          veiculos.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: AppSpacing.small(context)),

                        // ➕ ADICIONAR
                        ElevatedButton.icon(
                          onPressed: adicionarVeiculo,
                          icon: Icon(Icons.add),
                          label: Text('Adicionar veículo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),

                        SizedBox(height: AppSpacing.medium(context)),

                        // 🚀 SALVAR
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: salvarTodos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              widget.veiculo != null
                                  ? 'Atualizar'
                                  : 'Salvar todos',
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

  // 🔧 CAMPO PADRÃO COM VALIDAÇÃO
  Widget campoObrigatorio(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small(context)),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label é obrigatório';
          }
          return null;
        },
      ),
    );
  }
}

class VeiculoForm {
  String? id;

  TextEditingController tipo = TextEditingController();
  TextEditingController marca = TextEditingController();
  TextEditingController modelo = TextEditingController();
  TextEditingController placa = TextEditingController();
  TextEditingController cor = TextEditingController();
  TextEditingController dataInstalacao = TextEditingController();
  TextEditingController diaPagamento = TextEditingController();
  TextEditingController valor = TextEditingController();
}
