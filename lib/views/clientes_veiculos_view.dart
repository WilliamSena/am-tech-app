import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/veiculo_controller.dart';
import '../models/cliente_model.dart';
import '../models/veiculo_model.dart';
import '../views/cadastro_veiculo_view.dart';

class ClientesVeiculosView extends StatefulWidget {
  const ClientesVeiculosView({super.key});

  @override
  State<ClientesVeiculosView> createState() => _ClientesVeiculosViewState();
}

class _ClientesVeiculosViewState extends State<ClientesVeiculosView> {
  final clienteController = ClienteController();
  final veiculoController = VeiculoController();

  final Color primaryColor = Color(0xFF1E88E5);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  Future<bool> confirmarExclusao() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmar exclusão"),
            content: Text("Deseja excluir este veículo?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
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
      body: Column(
        children: [
          header(context),

          Expanded(
            child: StreamBuilder<List<Cliente>>(
              stream: clienteController.listar(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var clientes = snapshot.data!;

                if (clientes.isEmpty) {
                  return Center(
                    child: Text("Nenhum cliente cadastrado"),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.medium(context)),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return clienteCard(cliente);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
            "Clientes & Veículos",
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

  Widget clienteCard(Cliente cliente) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.medium(context)),
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
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium(context),
          vertical: AppSpacing.small(context),
        ),
        childrenPadding: EdgeInsets.only(
          bottom: AppSpacing.medium(context),
        ),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: primaryColor),
        ),
        title: Text(
          cliente.nome,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(cliente.cpf),
        children: [
          StreamBuilder<List<Veiculo>>(
            stream: veiculoController.listarPorCliente(cliente.id!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              var veiculos = snapshot.data!;

              if (veiculos.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Nenhum veículo"),
                );
              }

              return Column(
                children: veiculos.map((v) {
                  return veiculoCard(cliente, v);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget veiculoCard(Cliente cliente, Veiculo v) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium(context),
        vertical: 6,
      ),
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.directions_car),
          ),
          SizedBox(width: AppSpacing.medium(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${v.marca} ${v.modelo}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text("Placa: ${v.placa}"),
                SizedBox(height: 4),
                Text(
                  v.status ? "Ativo" : "Inativo",
                  style: TextStyle(
                    color: v.status ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroVeiculoView(
                        idCliente: cliente.id,
                        nomeCliente: cliente.nome,
                        veiculo: v,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool confirmou = await confirmarExclusao();

                  if (!confirmou) return;

                  await veiculoController.excluir(v.id!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veículo excluído com sucesso"),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}