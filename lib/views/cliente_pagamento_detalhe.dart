import 'package:flutter/material.dart';
import '../models/cliente_pagamento_model.dart';
import '../models/veiculo_model.dart';
import '../controllers/cliente_pagamento_controller.dart';
import '../controllers/veiculo_controller.dart';
import '../services/pagamento_service.dart';

class ClientePagamentoDetalheView extends StatefulWidget {
  final ClientePagamento pagamento;
  final String nomeCliente;

  const ClientePagamentoDetalheView({
    super.key,
    required this.pagamento,
    required this.nomeCliente,
  });

  @override
  State<ClientePagamentoDetalheView> createState() =>
      _ClientePagamentoDetalheViewState();
}

class _ClientePagamentoDetalheViewState
    extends State<ClientePagamentoDetalheView> {
  final controller = ClientePagamentoController();
  final veiculoController = VeiculoController();

  @override
  Widget build(BuildContext context) {
    final p = widget.pagamento;

    return Scaffold(
      appBar: AppBar(title: Text('Detalhe do Boleto')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER
            Text(widget.nomeCliente,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            // 🔹 CARD PRINCIPAL
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'R\$ ${p.valorPagar.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Vencimento: ${p.dataVencimento.day}/${p.dataVencimento.month}/${p.dataVencimento.year}',
                    ),
                    SizedBox(height: 10),
                    Chip(
                      label: Text(p.status),
                      backgroundColor: p.status == 'PAGO'
                          ? Colors.green
                          : p.status == 'ATRASADO'
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 VEÍCULOS VINCULADOS
            Text('Veículos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            FutureBuilder<List<Veiculo>>(
              future: veiculoController.buscarPorIds(p.idsVeiculos),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                var lista = snapshot.data!;

                return Column(
                  children: lista.map((v) {
                    return ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text('${v.marca} ${v.modelo}'),
                      subtitle: Text('Placa: ${v.placa}'),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 20),

            // 🔹 HISTÓRICO
            Text('Histórico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ListTile(
              title: Text('Criado'),
              subtitle: Text(
                '${p.dataVencimento.day}/${p.dataVencimento.month}',
              ),
            ),

            ListTile(
              title: Text('Pagamento'),
              subtitle: Text(
                p.dataPagamentoRealizado != null
                    ? '${p.dataPagamentoRealizado!.day}/${p.dataPagamentoRealizado!.month}'
                    : 'Não pago',
              ),
            ),

            SizedBox(height: 30),

            // 🔥 BOTÕES
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text('Pagar'),
              onPressed: p.status == 'PAGO'
                  ? null
                  : () => confirmarPagamento(context, p),
            ),

            SizedBox(height: 10),

            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Editar'),
              onPressed: () {
                // você pode abrir tela de edição aqui
              },
            ),

            SizedBox(height: 10),

            ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Text('Excluir'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                p.status = 'INATIVO';
                await controller.atualizar(p);

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CONFIRMAÇÃO DE PAGAMENTO
  void confirmarPagamento(BuildContext context, ClientePagamento p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar pagamento'),
        content: Text('Deseja marcar este boleto como pago?'),
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

              await controller.atualizar(p);

              await gerarProximoBoleto(p);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pagamento realizado')),
              );

              Navigator.pop(context);
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}