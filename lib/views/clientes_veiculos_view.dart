import 'package:flutter/material.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/veiculo_controller.dart';
import '../models/cliente_model.dart';
import '../models/veiculo_model.dart';
import '../views/cadastro_veiculo_view.dart';

class ClientesVeiculosView extends StatelessWidget {
  final clienteController = ClienteController();
  final veiculoController = VeiculoController();

  ClientesVeiculosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clientes & Veículos')),
      body: StreamBuilder<List<Cliente>>(
        stream: clienteController.listar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var clientes = snapshot.data!;

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              var cliente = clientes[index];

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text(cliente.nome),
                  subtitle: Text(cliente.cpf),
                  children: [
                    StreamBuilder<List<Veiculo>>(
                      stream: veiculoController.listarPorCliente(cliente.id!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        var veiculos = snapshot.data!;

                        if (veiculos.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('Nenhum veículo'),
                          );
                        }

                        return Column(
                          children: veiculos.map((v) {
                            return ListTile(
                              leading: Icon(Icons.directions_car),
                              title: Text('${v.marca} ${v.modelo}'),
                              subtitle: Text('Placa: ${v.placa}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✏️ EDITAR
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
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

                                  // STATUS
                                  Text(
                                    v.status ? 'Ativo' : 'Inativo',
                                    style: TextStyle(
                                      color: v.status
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
