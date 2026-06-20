import 'package:am_tech/models/cliente_model.dart';
import 'package:flutter/material.dart';
import '../models/cliente_pagamento_model.dart';
import '../models/veiculo_model.dart';
import '../controllers/cliente_pagamento_controller.dart';
import '../controllers/veiculo_controller.dart';
import '../services/pagamento_service.dart';

class ClientePagamentoDetalheView extends StatefulWidget {
  final ClientePagamento pagamento;
  final Cliente cliente;

  const ClientePagamentoDetalheView({
    super.key,
    required this.pagamento,
    required this.cliente,
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

    Color statusColor;
    Color statusBg;

    switch (p.status) {
      case 'PAGO':
        statusColor = Colors.green;
        statusBg = Colors.green.withValues(alpha: 0.12);
        break;
      case 'ATRASADO':
        statusColor = Colors.red;
        statusBg = Colors.red.withValues(alpha: 0.12);
        break;
      default:
        statusColor = Colors.orange;
        statusBg = Colors.orange.withValues(alpha: 0.12);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detalhe do Boleto'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CLIENTE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cliente.nome,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CPF: ${widget.cliente.cpf}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD PRINCIPAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Valor do boleto',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'R\$ ${p.valorPagar.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vencimento: ${p.dataVencimento.day}/${p.dataVencimento.month}/${p.dataVencimento.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
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

            const SizedBox(height: 24),

            const Text(
              'Veículos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<Veiculo>>(
              future: veiculoController.buscarPorIds(p.idsVeiculos),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var lista = snapshot.data!;

                return Column(
                  children: lista.map((v) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        title: Text('${v.marca} ${v.modelo}'),
                        subtitle: Text('Placa: ${v.placa}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Criado'),
                    subtitle: Text(
                      '${p.dataVencimento.day}/${p.dataVencimento.month}/${p.dataVencimento.year}',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: const Text('Pagamento'),
                    subtitle: Text(
                      p.dataPagamentoRealizado != null
                          ? '${p.dataPagamentoRealizado!.day}/${p.dataPagamentoRealizado!.month}/${p.dataPagamentoRealizado!.year}'
                          : 'Não pago',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Pagar'),
                onPressed: p.status == 'PAGO'
                    ? null
                    : () => confirmarPagamento(context, p),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Excluir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  p.status = 'INATIVO';
                  await controller.atualizar(p);

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmarPagamento(BuildContext context, ClientePagamento p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pagamento'),
        content: const Text('Deseja marcar este boleto como pago?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              p.dataPagamentoRealizado = DateTime.now();
              p.status = 'PAGO';

              await controller.atualizar(p);
              await gerarProximoBoleto(p);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pagamento realizado')),
              );

              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}