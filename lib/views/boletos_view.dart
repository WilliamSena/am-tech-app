import 'package:flutter/material.dart';
import 'package:am_tech/controllers/cliente_pagamento_controller.dart';
import 'package:am_tech/controllers/cliente_controller.dart';
import 'package:am_tech/models/cliente_pagamento_model.dart';
import 'package:am_tech/models/cliente_model.dart';
import 'package:am_tech/theme/app_spacing.dart';

class BoletosView extends StatelessWidget {
  final controller = ClientePagamentoController();

  final Color primaryColor = Color(0xFF66B5FF);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  BoletosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          header(context),
          Expanded(
            child: StreamBuilder<List<ClientePagamento>>(
              stream: controller.service.listarTodos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var lista = snapshot.data!;

                // 🔥 AGRUPAR POR MÊS
                Map<String, List<ClientePagamento>> agrupado = {};

                for (var p in lista) {
                  String chave =
                      "${p.dataVencimento.month}/${p.dataVencimento.year}";

                  agrupado.putIfAbsent(chave, () => []).add(p);
                }

                var meses = agrupado.keys.toList();

                return ListView(
                  padding: EdgeInsets.all(AppSpacing.medium(context)),
                  children: meses.map((mes) {
                    var boletos = agrupado[mes]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tituloMes(context, mes),
                        ...boletos.map((p) => boletoCard(context, p)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔝 HEADER
  Widget header(BuildContext context) {
    return Container(
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
            "Boletos",
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

  // 📅 TÍTULO DO MÊS
  Widget tituloMes(BuildContext context, String mes) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.small(context)),
      child: Text(
        mes,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
      ),
    );
  }

  // 🧊 CARD BOLETO
  Widget boletoCard(BuildContext context, ClientePagamento p) {
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

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.small(context)),
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: FutureBuilder<Cliente?>(
        future: ClienteController().buscarPorId(p.idCliente),
        builder: (context, snapCliente) {
          String nome = snapCliente.data?.nome ?? '...';

          return Row(
            children: [
              // ÍCONE
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: Icon(Icons.receipt, color: statusColor),
              ),

              SizedBox(width: AppSpacing.medium(context)),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$ ${p.valorPagar.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // STATUS
              Text(
                p.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}