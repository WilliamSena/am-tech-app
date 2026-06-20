import 'package:am_tech/controllers/cliente_controller.dart';
import 'package:am_tech/controllers/cliente_pagamento_controller.dart';
import 'package:am_tech/models/cliente_model.dart';
import 'package:am_tech/models/cliente_pagamento_model.dart';
import 'package:am_tech/views/cadastro_cliente_view.dart';
import 'package:am_tech/views/cadastro_veiculo_view.dart';
import 'package:am_tech/views/cliente_pagamento_detalhe.dart';
import 'package:am_tech/views/cliente_view.dart';
import 'package:am_tech/views/clientes_veiculos_view.dart';
import 'package:flutter/material.dart';

class ResumoView extends StatefulWidget {
  const ResumoView({super.key});

  @override
  _ResumoView createState() => _ResumoView();
}

class _ResumoView extends State<ResumoView> {
  DateTime mesSelecionado = DateTime.now(); // 🔥 AQUI
  bool isMesmoMes(DateTime data) {
    return data.month == mesSelecionado.month &&
        data.year == mesSelecionado.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: Drawer(
        child: Column(
          children: [
            // 🔝 CABEÇALHO
            UserAccountsDrawerHeader(
              accountName: Text('Usuário'),
              accountEmail: Text('usuario@email.com'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),

            // 📋 MENU
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Resumo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ExpansionTile(
              title: Text('Clientes'),
              leading: Icon(Icons.people),
              initiallyExpanded: false,
              childrenPadding: EdgeInsets.only(left: 20),
              children: [
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Cadastrar'),
                  onTap: () {
                    Navigator.pop(context); //Fecha o drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CadastroClienteView()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Listar'),
                  onTap: () {
                    Navigator.pop(context); //Fecha o drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClientesView()),
                    );
                  },
                ),
              ],
            ),

            ExpansionTile(
              title: Text('Veículos'),
              leading: Icon(Icons.directions_car),
              initiallyExpanded: false,
              childrenPadding: EdgeInsets.only(left: 20),
              children: [
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Cadastrar'),
                  onTap: () {
                    Navigator.pop(context); //Fecha o drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CadastroVeiculoView()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Listar'),
                  onTap: () {
                    Navigator.pop(context); //Fecha o drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClientesVeiculosView()),
                    );
                  },
                ),
              ],
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sair'),
              onTap: () {
                // implementar logout depois
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔝 HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  Text(
                    'AM TECH',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 30), // alinhamento
                ],
              ),
            ),

            // 📊 CARDS
            /*Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  cardClick(
                    //cardTexto("CLIENTES", "10"),
                    cardIcon(Icons.person, "10"),
                    () {
                      Navigator.push(context, criarRota(ClientesView()));
                    },
                  ),
                  cardAnimado(cardIcon(Icons.directions_car, "10"), 1),
                  cardAnimado(cardTexto("SALDO", "R\$ 1000,00"), 2),
                  cardAnimado(cardTexto("RECEITA", "R\$ 1000,00"), 3),
                  cardAnimado(cardTexto("DESPESA", "R\$ 1000,00"), 4),
                  cardAnimado(cardTexto("LUCRO", "R\$ 1000,00"), 5),
                ],
              ),
            ),*/
            GridView.count(
              crossAxisCount: 3,
              padding: EdgeInsets.all(16),
              crossAxisSpacing: 40,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              shrinkWrap: true, // 🔥 ESSENCIAL
              physics: NeverScrollableScrollPhysics(), // 🔥 ESSENCIAL
              children: [
                cardClick(cardIcon(Icons.person, "6"), () {
                  Navigator.push(context, criarRota(ClientesView()));
                }),
                cardClick(cardIcon(Icons.directions_car, "10"), (){
                  Navigator.push(context, criarRota(ClientesVeiculosView()));
                }),
                cardAnimado(cardTexto("SALDO", "R\$ 1000,00"), 2),
                cardAnimado(cardTexto("RECEITA", "R\$ 1000,00"), 3),
                cardAnimado(cardTexto("DESPESA", "R\$ 1000,00"), 4),
                cardAnimado(cardTexto("LUCRO", "R\$ 1000,00"), 5),
              ],
            ),

            // 🔥 FILTRO COMEÇA AQUI
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Boletos do mês',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      DateTime? data = await showDatePicker(
                        context: context,
                        initialDate: mesSelecionado,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (data != null) {
                        setState(() {
                          mesSelecionado = data;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_month),
                    label: Text(
                      '${mesSelecionado.month}/${mesSelecionado.year}',
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder<List<ClientePagamento>>(
              stream: ClientePagamentoController().service.listarTodos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var lista = snapshot.data!
                    .where((p) => isMesmoMes(p.dataVencimento))
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

                        return ListTile(
                          leading: Icon(Icons.receipt),
                          title: Text(nome),
                          subtitle: Text(
                            'R\$ ${p.valorPagar.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            p.status,
                            style: TextStyle(
                              color: p.status == 'PAGO'
                                  ? Colors.green
                                  : p.status == 'ATRASADO'
                                  ? Colors.red
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 🔥 AQUI
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
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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

  Widget cardClick(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: child,
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