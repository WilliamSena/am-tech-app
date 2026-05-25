import 'package:flutter/material.dart';
import '../controllers/despesa_controller.dart';
import '../models/despesa_model.dart';

class CadastroDespesaView extends StatefulWidget {
  const CadastroDespesaView({super.key});

  @override
  State<CadastroDespesaView> createState() => _CadastroDespesaViewState();
}

class _CadastroDespesaViewState extends State<CadastroDespesaView> {
  final controller = DespesaController();

  final descricaoController = TextEditingController();
  final categoriaController = TextEditingController();
  final valorController = TextEditingController();

  String status = 'Pendente';
  String tipo = 'Mensal';

  DateTime dataRegistro = DateTime.now();
  DateTime diaPagamento = DateTime.now();

  Future<void> selecionarDataPagamento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: diaPagamento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        diaPagamento = data;
      });
    }
  }

  Future<void> salvar() async {
    final despesa = Despesa(
      descricao: descricaoController.text,
      categoria: categoriaController.text,
      valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0,
      status: status,
      dataRegistro: dataRegistro,
      diaPagamento: diaPagamento,
      tipo: tipo,
    );

    await controller.cadastrarDespesa(despesa);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despesa cadastrada com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Despesa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor'),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                DropdownMenuItem(value: 'Pago', child: Text('Pago')),
              ],
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: tipo,
              items: const [
                DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                DropdownMenuItem(value: 'Único', child: Text('Único')),
              ],
              onChanged: (value) {
                setState(() {
                  tipo = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pagamento: ${diaPagamento.day}/${diaPagamento.month}/${diaPagamento.year}',
                  ),
                ),
                ElevatedButton(
                  onPressed: selecionarDataPagamento,
                  child: const Text('Selecionar'),
                ),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
