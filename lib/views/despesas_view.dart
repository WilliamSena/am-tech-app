import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../controllers/despesa_controller.dart';
import '../models/despesa_model.dart';

class DespesasView extends StatefulWidget {
  const DespesasView({super.key});

  @override
  State<DespesasView> createState() => _DespesasViewState();
}

class _DespesasViewState extends State<DespesasView> {
  final controller = DespesaController();

  final Color primaryColor = Color(0xFF1E88E5);
  final Color secondaryColor = Color(0xFF0D47A1);
  final Color bgColor = Color(0xFFF5F7FA);

  DateTime mesSelecionado = DateTime.now();

  bool isMesmoMes(DateTime data) {
    return data.month == mesSelecionado.month &&
        data.year == mesSelecionado.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // abrir cadastro
        },
      ),

      body: Column(
        children: [
          header(context),

          Expanded(
            child: StreamBuilder<List<Despesa>>(
              stream: controller.listarDespesas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var despesas = snapshot.data!;

                // 🔵 MENSAIS
                var mensais = despesas.where((d) {
                  return d.tipo.toLowerCase() == 'mensal';
                }).toList();

                // 🟠 GASTOS DO MÊS
                var gastosMes = despesas.where((d) {
                  return d.tipo.toLowerCase() == 'único' &&
                      isMesmoMes(d.dataRegistro);
                }).toList();

                double totalMensais = mensais.fold(
                  0,
                  (total, item) => total + (item.valor ?? 0),
                );

                double totalMes = gastosMes.fold(
                  0,
                  (total, item) => total + (item.valor ?? 0),
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.medium(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 RESUMO
                      resumoFinanceiro(context, totalMensais, totalMes),

                      SizedBox(height: AppSpacing.medium(context)),

                      // 📅 FILTRO
                      filtroMes(),

                      SizedBox(height: AppSpacing.large(context)),

                      // 🔵 MENSAIS
                      tituloSessao(context, Icons.repeat, "Despesas Mensais"),

                      SizedBox(height: AppSpacing.medium(context)),

                      if (mensais.isEmpty)
                        vazio("Nenhuma despesa mensal")
                      else
                        ...mensais.map(
                          (d) =>
                              despesaCard(context, despesa: d, isMensal: true),
                        ),

                      SizedBox(height: AppSpacing.large(context)),

                      // 🟠 GASTOS DO MÊS
                      tituloSessao(
                        context,
                        Icons.calendar_month,
                        "Gastos do Mês",
                      ),

                      SizedBox(height: AppSpacing.medium(context)),

                      if (gastosMes.isEmpty)
                        vazio("Nenhum gasto este mês")
                      else
                        ...gastosMes.map(
                          (d) =>
                              despesaCard(context, despesa: d, isMensal: false),
                        ),
                    ],
                  ),
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
        55,
        AppSpacing.medium(context),
        25,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
            "Despesas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 RESUMO
  Widget resumoFinanceiro(BuildContext context, double mensais, double mes) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          resumoItem("Mensais", mensais, Icons.repeat),

          resumoItem("Mês", mes, Icons.calendar_today),

          resumoItem("Total", mensais + mes, Icons.attach_money),
        ],
      ),
    );
  }

  Widget resumoItem(String titulo, double valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryColor),

        SizedBox(height: 6),

        Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 4),

        Text(
          "R\$ ${valor.toStringAsFixed(2)}",
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 📅 FILTRO
  /*Widget filtroMes() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            setState(() {
              mesSelecionado = data;
            });
          }
        },
        icon: Icon(Icons.calendar_month),
        label: Text("${mesSelecionado.month}/${mesSelecionado.year}"),
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
      child:
        // 📅 CALENDÁRIO
        Container(
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
              // ⬅️ VOLTAR MÊS
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

              SizedBox(width: AppSpacing.medium(context)),

              // 📅 MÊS ATUAL
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
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),

              SizedBox(width: AppSpacing.medium(context)),

              // ➡️ AVANÇAR MÊS
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

  // 🧾 TÍTULO SESSÃO
  Widget tituloSessao(BuildContext context, IconData icon, String titulo) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),

        SizedBox(width: AppSpacing.small(context)),

        Text(
          titulo,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 💳 CARD DESPESA
  Widget despesaCard(
    BuildContext context, {
    required Despesa despesa,
    required bool isMensal,
  }) {
    Color statusColor = Colors.orange;

    if (despesa.status == 'PAGO') {
      statusColor = Colors.green;
    }

    if (despesa.status == 'ATRASADO') {
      statusColor = Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.medium(context)),
      padding: EdgeInsets.all(AppSpacing.medium(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // 🔵 ÍCONE
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isMensal ? Icons.repeat : Icons.attach_money,
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
                  despesa.descricao,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                SizedBox(height: 6),

                /*Text(
                  "Tipo: ${despesa.tipo}",
                  style: TextStyle(color: Colors.grey[700]),
                ),

                SizedBox(height: 4),*/

                Text(
                  isMensal
                      ? "Dia pagamento: ${despesa.diaPagamento.day}"
                      : "Registro: ${despesa.dataRegistro.day}/${despesa.dataRegistro.month}/${despesa.dataRegistro.year}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // 💰 VALOR + STATUS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "R\$ ${despesa.valor}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: secondaryColor,
                ),
              ),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  despesa.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📭 VAZIO
  Widget vazio(String texto) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(texto, style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
