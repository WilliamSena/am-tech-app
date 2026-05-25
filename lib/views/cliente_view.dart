import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente_model.dart';
import 'cadastro_cliente_view.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  _ClientesView createState() => _ClientesView();
}

class _ClientesView extends State<ClientesView> {
  final controller = ClienteController();
  final buscaController = TextEditingController();
  String busca = "";

  final Color primaryColor = Color(0xFF1E88E5);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  Future<bool> confirmarExclusao() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar exclusão"),
            content: Text("Tem certeza que deseja excluir este cliente?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: Text("Excluir"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 BOTÃO FLUTUANTE MODERNO
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CadastroClienteView()),
          );
        },
      ),

      body: Column(
        children: [
          header(context),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.medium(context),
              vertical: AppSpacing.small(context),
            ),
            child: TextField(
              controller: buscaController,
              onChanged: (value) {
                setState(() {
                  busca = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.medium(context)),

          Expanded(
            child: StreamBuilder<List<Cliente>>(
              stream: controller.listar(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var clientes = snapshot.data!;

                if (busca.isNotEmpty) {
                  clientes = clientes.where((c) {
                    return c.nome.toLowerCase().contains(busca) ||
                        c.cpf.contains(busca);
                  }).toList();
                }

                if (clientes.isEmpty) {
                  return Center(child: Text("Nenhum cliente cadastrado"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium(context),
                  ),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    var c = clientes[index];
                    return clienteCard(context, c);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔝 HEADER PADRÃO DO APP
  Widget header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium(context),
        50,
        AppSpacing.medium(context),
        AppSpacing.medium(context),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
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
            "Clientes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🧊 CARD MODERNO DE CLIENTE
  Widget clienteCard(BuildContext context, Cliente c) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.medium(context)),
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // 🔵 ÍCONE
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: primaryColor),
          ),

          SizedBox(width: AppSpacing.medium(context)),

          // 📄 DADOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.nome,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: AppSpacing.small(context)),
                Text(c.cpf, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),

          // ✏️ AÇÕES
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroClienteView(cliente: c),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool confirmou = await confirmarExclusao();

                  if (!confirmou) return;

                  await controller.excluir(c.id!);

                  // 🔥 feedback pro usuário
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cliente excluído com sucesso")),
                  );

                  // 🔥 atualiza tela
                  //setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
