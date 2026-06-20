import 'package:am_tech/controllers/despesa_controller.dart';
import 'package:am_tech/models/despesa_model.dart';
import 'package:am_tech/services/app_version_service.dart';
import 'package:am_tech/views/boletos_view.dart';
import 'package:am_tech/views/cadastro_despesa_view.dart';
import 'package:am_tech/views/cliente_pagamento_detalhe.dart';
import 'package:am_tech/views/despesas_view.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'package:am_tech/controllers/cliente_controller.dart';
import 'package:am_tech/controllers/veiculo_controller.dart';
import 'package:am_tech/controllers/cliente_pagamento_controller.dart';
import 'package:am_tech/models/cliente_model.dart';
import 'package:am_tech/models/cliente_pagamento_model.dart';
import 'package:am_tech/models/veiculo_model.dart';
import 'package:am_tech/views/cadastro_cliente_view.dart';
import 'package:am_tech/views/cadastro_veiculo_view.dart';
import 'package:am_tech/views/cliente_view.dart';
import 'package:am_tech/views/clientes_veiculos_view.dart';

class TelaInicialView extends StatefulWidget {
  const TelaInicialView({super.key});

  @override
  _TelaInicialView createState() => _TelaInicialView();
}

class _TelaInicialView extends State<TelaInicialView> {
  final Color primaryColor = Color(0xFF66B5FF);
  final Color secondaryColor = Color(0xFF3482F7);
  final Color bgColor = Color(0xFFF5F7FA);

  final ScrollController _scrollController = ScrollController();
  bool mostrarBotaoTopo = false;

  DateTime mesSelecionado = DateTime.now(); // 🔥 AQUI
  bool isMesmoMes(DateTime data) {
    return data.month == mesSelecionado.month &&
        data.year == mesSelecionado.year;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !mostrarBotaoTopo) {
        setState(() {
          mostrarBotaoTopo = true;
        });
      } else if (_scrollController.offset <= 300 && mostrarBotaoTopo) {
        setState(() {
          mostrarBotaoTopo = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: drawerCustom(),
      floatingActionButton: mostrarBotaoTopo
          ? /*FloatingActionButton.extended(
              onPressed: () {},
              icon: Icon(Icons.arrow_upward),
              label: Text("Topo"),
            )*/
          FloatingActionButton(
              backgroundColor: secondaryColor,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            headerTop(context),

            /*
            Expanded dentro de SingleChildScrollView costuma gerar comportamento estranho / layout inconsistente.

              Ideal seria remover:

              Expanded(child: dashboardResumoClientes(context))
              Expanded(child: dashboardResumoSaldo(context))

              E usar só:

              dashboardResumoClientes(context),
              dashboardResumoSaldo(context),

              Isso pode inclusive estar afetando scroll.
             */
            Expanded(child: (dashboardResumoClientes(context))),

            Expanded(child: (dashboardResumoSaldo(context))),

            // 🔥 SOBE O CONTEÚDO PRA COLAR NO HEADER
            Transform.translate(
              offset: Offset(0, AppSpacing.large(context)),
              child: Column(
                children: [
                  filtroMes(),

                  SizedBox(height: AppSpacing.large(context)),

                  // 📄 SEGUNDO BLOCO (boletos)
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
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Boletos do período",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),

                          SizedBox(height: AppSpacing.medium(context)),

                          listaBoletos(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.medium(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerCustom() {
    return Drawer(
      child: Column(
        children: [
          // 🔝 HEADER PERSONALIZADO
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium(context),
              50,
              AppSpacing.medium(context),
              AppSpacing.medium(context),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: primaryColor, size: 30),
                ),
                SizedBox(height: AppSpacing.small(context)),
                Text(
                  'Usuário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'usuario@email.com',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          FutureBuilder<String>(
            future: AppVersionService().getVersaoCompleta(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              return Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Versão ${snapshot.data}",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          ),

          SizedBox(height: AppSpacing.medium(context)),

          // 📋 MENU PRINCIPAL
          itemMenu(Icons.home, "Resumo", () {
            Navigator.pop(context);
          }),

          grupoMenu(
            icon: Icons.people,
            titulo: "Clientes",
            children: [
              itemMenu(Icons.add, "Cadastrar", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroClienteView()),
                );
              }),
              itemMenu(Icons.list, "Listar", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClientesView()),
                );
              }),
            ],
          ),

          grupoMenu(
            icon: Icons.directions_car,
            titulo: "Veículos",
            children: [
              itemMenu(Icons.add, "Cadastrar", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroVeiculoView()),
                );
              }),
              itemMenu(Icons.list, "Listar", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClientesVeiculosView()),
                );
              }),
            ],
          ),
          grupoMenu(
            icon: Icons.directions_car,
            titulo: "Despesas",
            children: [
              itemMenu(Icons.airplane_ticket, "Cadastro", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroDespesaView()),
                );
              }),
              itemMenu(Icons.list, "Listar", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DespesasView()),
                );
              }),
            ],
          ),

          itemMenu(Icons.receipt_long, "Boletos", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BoletosView()),
            );
          }),

          Spacer(),

          Divider(),

          // 🚪 LOGOUT
          itemMenu(Icons.logout, "Sair", () {
            // implementar logout
          }, color: Colors.red),

          SizedBox(height: AppSpacing.small(context)),
        ],
      ),
    );
  }

  Widget itemMenu(
    IconData icon,
    String titulo,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium(context),
        vertical: AppSpacing.small(context),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.medium(context)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, color: color ?? primaryColor),
              SizedBox(width: AppSpacing.medium(context)),
              Text(
                titulo,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget grupoMenu({
    required IconData icon,
    required String titulo,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.small(context)),
      child: ExpansionTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: EdgeInsets.only(left: AppSpacing.medium(context)),
        children: children,
      ),
    );
  }

  Widget headerTop(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 50, 16, 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MENU
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),

          // 🔥 LOGO CENTRAL
          Column(
            children: [
              Image.asset(
                'assets/logo-horizontal.png',
                height: 50, // ajuste fino aqui
              ),
              SizedBox(height: 5),
            ],
          ),

          // PERFIL
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget dashboardResumoClientes(BuildContext context) {
    return StreamBuilder<List<Cliente>>(
      stream: ClienteController().listar(),
      builder: (context, snapClientes) {
        return StreamBuilder<List<Veiculo>>(
          stream: VeiculoController().listarTodos(),
          builder: (context, snapVeiculos) {
            if (!snapClientes.hasData || !snapVeiculos.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            //Clientes ativos
            var clientesAtivos = snapClientes.data!;

            // 🔥 IDS DOS CLIENTES
            var idsClientes = clientesAtivos.map((c) => c.id).toSet();

            //Veiculos
            var veiculos = snapVeiculos.data!
                .where(
                  (v) => v.status == true && idsClientes.contains(v.idCliente),
                )
                .length;

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.medium(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  resumoClientes(context, clientesAtivos.length, veiculos),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget dashboardResumoSaldo(BuildContext context) {
    return StreamBuilder<List<ClientePagamento>>(
      stream: ClientePagamentoController().listarTodos(),
      builder: (context, snapReceitas) {
        return StreamBuilder<List<Despesa>>(
          stream: DespesaController().listarDespesas(),
          builder: (context, snapDespesas) {
            if (!snapReceitas.hasData || !snapDespesas.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // 💰 RECEITAS
            var receitas = snapReceitas.data!
                .where(
                  (p) =>
                      p.status == 'PAGO' &&
                      p.dataPagamentoRealizado != null &&
                      isMesmoMes(p.dataPagamentoRealizado!),
                )
                .toList();

            double totalReceitas = receitas.fold(
              0,
              (soma, p) => soma + p.valorPagar,
            );

            // 💸 DESPESAS
            var despesas = snapDespesas.data!
                .where(
                  (d) =>
                      d.status.toUpperCase() == 'PAGO' &&
                      isMesmoMes(d.dataRegistro),
                )
                .toList();

            double totalDespesas = despesas.fold(
              0,
              (soma, d) => soma + d.valor,
            );

            // 📈 LUCRO
            double lucro = totalReceitas - totalDespesas;

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.small(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 RESUMO
                  resumoFinanceiro(
                    context,
                    totalReceitas,
                    totalDespesas,
                    lucro,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget resumoClientes(BuildContext context, int clientes, int veiculos) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: itemClientes(
                "Clientes",
                clientes.toString(),
                Icons.person,
                Colors.white,
              ),
            ),
          ),

          SizedBox(width: AppSpacing.large(context)),

          Expanded(
            child: Center(
              child: itemClientes(
                "Veículos",
                veiculos.toString(),
                Icons.directions_car,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resumoFinanceiro(
    BuildContext context,
    double receita,
    double despesa,
    double lucro,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.small(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Saldo do mês",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: AppSpacing.small(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              itemResumo(
                "Receitas",
                receita,
                Icons.arrow_downward,
                Colors.greenAccent,
              ),
              itemResumo(
                "Despesas",
                despesa,
                Icons.arrow_upward,
                Colors.redAccent,
              ),
              itemResumo("Lucro", lucro, Icons.money, Colors.greenAccent),
            ],
          ),
          SizedBox(height: AppSpacing.small(context)),
        ],
      ),
    );
  }

  Widget itemClientes(String titulo, String valor, IconData icon, Color cor) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ÍCONE
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cor),
          ),

          SizedBox(width: 12),

          // TEXTO
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              SizedBox(height: 2),

              Text(
                valor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget itemResumo(String titulo, double valor, IconData icon, Color cor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cor),
        ),

        SizedBox(width: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(color: Colors.white70, fontSize: 12)),

            Text(
              "R\$ ${valor.toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget dashboardGrid(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = width < 600 ? 2 : 3;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.medium(context),
        mainAxisSpacing: AppSpacing.medium(context),
        childAspectRatio: MediaQuery.of(context).size.width < 360 ? 1.1 : 1.4,
        children: [
          // 👇 CLIENTES ATIVOS
          StreamBuilder<List<Cliente>>(
            stream: ClienteController().listar(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return cardDashboard(Icons.person, "Clientes", "...");
              }

              var total = snapshot.data!.where((c) => c.status == true).length;

              return cardDashboard(
                Icons.person,
                "Clientes",
                total.toString(),
                () {
                  Navigator.push(context, criarRota(ClientesView()));
                },
              );
            },
          ),

          // 👇 VEÍCULOS APENAS DE CLIENTES ATIVOS
          StreamBuilder<List<Cliente>>(
            stream: ClienteController().listar(),
            builder: (context, snapClientes) {
              if (!snapClientes.hasData) {
                return cardDashboard(Icons.directions_car, "Veículos", "...");
              }

              // 🔥 pega IDs dos clientes ativos
              var clientesAtivos = snapClientes.data!
                  .where((c) => c.status == true)
                  .map((c) => c.id)
                  .toSet();

              return StreamBuilder<List<Veiculo>>(
                stream: VeiculoController().listarTodos(),
                builder: (context, snapVeiculos) {
                  if (!snapVeiculos.hasData) {
                    return cardDashboard(
                      Icons.directions_car,
                      "Veículos",
                      "...",
                    );
                  }

                  // 🔥 FILTRO CORRETO
                  var total = snapVeiculos.data!
                      .where(
                        (v) =>
                            v.status == true &&
                            clientesAtivos.contains(v.idCliente),
                      )
                      .length;

                  return cardDashboard(
                    Icons.directions_car,
                    "Veículos",
                    total.toString(),
                    () {
                      Navigator.push(
                        context,
                        criarRota(ClientesVeiculosView()),
                      );
                    },
                  );
                },
              );
            },
          ),

          // 👇 RECEITA DO MÊS (BOLETOS PAGOS)
          StreamBuilder<List<ClientePagamento>>(
            stream: ClientePagamentoController().listarTodos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return cardDashboard(Icons.attach_money, "Receita", "...");
              }

              var lista = snapshot.data!
                  .where(
                    (p) =>
                        p.status == 'PAGO' &&
                        p.dataPagamentoRealizado != null &&
                        isMesmoMes(p.dataPagamentoRealizado!),
                  )
                  .toList();

              double total = lista.fold(0, (soma, p) => soma + p.valorPagar);

              return cardDashboard(
                Icons.attach_money,
                "Receita",
                "R\$ ${total.toStringAsFixed(2)}",
              );
            },
          ),

          // 👇 DESPESA (pode deixar fixo por enquanto)
          //cardDashboard(Icons.money_off, "Despesa", "R\$ 0"),
          StreamBuilder<List<Despesa>>(
            stream: DespesaController().listarDespesas(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return cardDashboard(Icons.money_off, "Despesa", "R\$ 0");
              }

              var lista = snapshot.data!
                  .where(
                    (d) =>
                        d.status.toUpperCase() == 'PAGO' &&
                        isMesmoMes(d.dataRegistro),
                  )
                  .toList();
              double total = lista.fold(0, (soma, d) => soma + d.valor);

              return cardDashboard(
                Icons.money_off,
                "Despesa",
                "R\$ ${total.toStringAsFixed(2)}",
                () {
                  Navigator.push(context, criarRota(DespesasView()));
                },
                Colors.red,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget dashboardLista(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      child: Column(
        children: [
          cardDashboardHorizontal(Icons.people, "Clientes", "6", () {
            Navigator.push(context, criarRota(ClientesView()));
          }),

          cardDashboardHorizontal(Icons.directions_car, "Veículos", "10", () {
            Navigator.push(context, criarRota(ClientesVeiculosView()));
          }),

          cardDashboardHorizontal(Icons.attach_money, "Receita", "R\$ 1000"),

          cardDashboardHorizontal(Icons.money_off, "Despesa", "R\$ 500"),
        ],
      ),
    );
  }

  Widget cardDashboardHorizontal(
    IconData icon,
    String titulo,
    String valor, [
    VoidCallback? onTap,
  ]) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.medium(context)),
        padding: EdgeInsets.all(AppSpacing.medium(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🔵 ÍCONE
            Container(
              padding: EdgeInsets.all(AppSpacing.small(context)),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: width * 0.06),
            ),

            SizedBox(width: AppSpacing.medium(context)),

            // 📊 TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // 👉 SETA (opcional)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget cardDashboard(
    IconData icon,
    String titulo,
    String valor, [
    VoidCallback? onTap,
    Color? corValor,
  ]) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // 🔽 menor
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4, // 🔽 sombra mais leve
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppSpacing.small(context)), // 🔽 menor padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: width * 0.06, // 🔽 responsivo (antes fixo 30)
            ),

            SizedBox(height: AppSpacing.small(context)),

            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.04, // 🔽 menor
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2),

            Text(
              valor,
              style: TextStyle(
                fontSize: width * 0.035, // 🔽 menor
                color: corValor ?? secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget filtroBoletos() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Boletos do mês',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              DateTime? data = await showDatePicker(
                context: context,
                initialDate: mesSelecionado,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (data != null) {
                setState(() => mesSelecionado = data);
              }
            },
            icon: Icon(Icons.calendar_month),
            label: Text('${mesSelecionado.month}/${mesSelecionado.year}'),
          ),
        ],
      ),
    );
  }*/

  Widget filtroMes() {
    final meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium(context),
          vertical: AppSpacing.small(context),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⬅️ MÊS ANTERIOR
            IconButton(
              icon: Icon(Icons.chevron_left, color: primaryColor, size: 30),
              onPressed: () {
                setState(() {
                  mesSelecionado = DateTime(
                    mesSelecionado.year,
                    mesSelecionado.month - 1,
                  );
                });
              },
            ),

            SizedBox(width: AppSpacing.large(context)),

            // 📅 MÊS CENTRAL
            Column(
              children: [
                Text(
                  meses[mesSelecionado.month - 1],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  mesSelecionado.year.toString(),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),

            SizedBox(width: AppSpacing.large(context)),

            // ➡️ PRÓXIMO MÊS
            IconButton(
              icon: Icon(Icons.chevron_right, color: primaryColor, size: 30),
              onPressed: () {
                setState(() {
                  mesSelecionado = DateTime(
                    mesSelecionado.year,
                    mesSelecionado.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget listaBoletos() {
    return StreamBuilder<List<Cliente>>(
      stream: ClienteController().listar(),
      builder: (context, snapClientes) {
        if (!snapClientes.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var clientesAtivos = snapClientes.data!
            .where((c) => c.status == true)
            .map((c) => c.id)
            .toSet();

        return StreamBuilder<List<ClientePagamento>>(
          stream: ClientePagamentoController().service.listarTodos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var lista = snapshot.data!
                .where(
                  (p) =>
                      isMesmoMes(p.dataVencimento) &&
                      clientesAtivos.contains(p.idCliente),
                )
                .toList();

            lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));

            if (lista.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Nenhum boleto neste período',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: lista.map((p) {
                return FutureBuilder<Cliente?>(
                  future: ClienteController().buscarPorId(p.idCliente),
                  builder: (context, snapCliente) {
                    //String nome = snapCliente.data?.nome ?? '...';
                    final cliente = snapCliente.data;

                    Color statusColor;

                    switch (p.status) {
                      case 'PAGO':
                        statusColor = Colors.green;
                        break;

                      case 'ATRASADO':
                        statusColor = Colors.red;
                        break;

                      default:
                        statusColor = Colors.orange;
                    }

                    return GestureDetector(
                      onTap: cliente == null
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientePagamentoDetalheView(
                              pagamento: p,
                              cliente: cliente,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: AppSpacing.medium(context),
                        ),
                        padding: EdgeInsets.all(AppSpacing.medium(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            // 🔵 ÍCONE
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: primaryColor,
                              ),
                            ),

                            SizedBox(width: AppSpacing.medium(context)),

                            // 📄 DADOS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapCliente.data?.nome ?? '...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    'Vencimento: ${p.dataVencimento.day}/${p.dataVencimento.month}/${p.dataVencimento.year}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    'R\$ ${p.valorPagar.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: secondaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // STATUS
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                p.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  /*
  Widget listaBoletos() {
    return StreamBuilder<List<Cliente>>(
      stream: ClienteController().listar(),
      builder: (context, snapClientes) {
        if (!snapClientes.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // 🔥 IDs dos clientes ativos
        var clientesAtivos = snapClientes.data!
            .where((c) => c.status == true)
            .map((c) => c.id)
            .toSet();

        return StreamBuilder<List<ClientePagamento>>(
          stream: ClientePagamentoController().service.listarTodos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var lista = snapshot.data!
                .where(
                  (p) =>
                      isMesmoMes(p.dataVencimento) &&
                      clientesAtivos.contains(p.idCliente),
                ) // 🔥 FILTRO AQUI
                .toList();

            if (lista.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum boleto neste mês'),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: lista.map((p) {
                return FutureBuilder<Cliente?>(
                  future: ClienteController().buscarPorId(p.idCliente),
                  builder: (context, snapCliente) {
                    String nome = snapCliente.data?.nome ?? '...';

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientePagamentoDetalheView(
                                pagamento: p,
                                nomeCliente: nome,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.receipt, color: primaryColor),
                        ),
                        title: Text(nome),
                        subtitle: Text(
                          'R\$ ${p.valorPagar.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          p.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: p.status == 'PAGO'
                                ? Colors.green
                                : p.status == 'ATRASADO'
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
*/
  Route criarRota(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final tween = Tween(
          begin: Offset(1, 0), // direita → esquerda
          end: Offset.zero,
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // 🔹 CARD COM ÍCONE
  Widget cardIcon(IconData icon, String valor) {
    return Container(
      decoration: boxDecoration(),
      padding: EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 34),
          Text(
            valor,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🔹 CARD TEXTO
  Widget cardTexto(String titulo, String valor) {
    return Container(
      decoration: boxDecoration(),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 1),
          Text(valor, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget cardAnimado(Widget child, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget cardClick(BuildContext context, Widget child, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withValues(alpha: 0.2),
        highlightColor: primaryColor.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(AppSpacing.small(context)),
          child: child,
        ),
      ),
    );
  }

  // 🔹 ESTILO PADRÃO
  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black),
    );
  }
}

class CardClick extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const CardClick({super.key, required this.child, required this.onTap});

  @override
  State<CardClick> createState() => _CardClickState();
}

class _CardClickState extends State<CardClick> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapUp: (_) => setState(() => scale = 1.0),
      onTapCancel: () => setState(() => scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 100),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Color(0xFF1E88E5),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
