import 'package:am_tech/controllers/cliente_pagamento_controller.dart';
import 'package:am_tech/models/cliente_pagamento_model.dart';
import 'package:am_tech/services/pagamento_service.dart';
import 'package:flutter/material.dart';

class ClientePagamentoView extends StatelessWidget {
  final String idCliente;

  const ClientePagamentoView({super.key, required this.idCliente});

  @override
  Widget build(BuildContext context) {
    final controller = ClientePagamentoController();

    return Scaffold(
      appBar: AppBar(title: Text('Pagamentos')),

      body: StreamBuilder<List<ClientePagamento>>(
        stream: controller.listarPorCliente(idCliente),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var lista = snapshot.data!;

          // 🔥 AQUI
          WidgetsBinding.instance.addPostFrameCallback((_) {
            atualizarStatusBoletos(lista);
          });

          return ListView(
            children: lista.map((p) {
              return ListTile(
                title: Text('R\$ ${p.valorPagar}'),
                subtitle: Text(
                  'Vencimento: ${p.dataVencimento.day}/${p.dataVencimento.month}',
                ),
                // 🔥 AQUI
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Confirmar pagamento'),
                      content: Text('Deseja marcar como pago?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            p.dataPagamentoRealizado = DateTime.now();
                            p.status = 'PAGO';

                            await ClientePagamentoController().atualizar(p);

                            // 🔥 AQUI
                            await gerarProximoBoleto(p);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pagamento realizado!')),
                            );
                          },
                          child: Text('Confirmar'),
                        ),
                      ],
                    ),
                  );
                },
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
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
