import 'package:cloud_firestore/cloud_firestore.dart';

class Despesa {
  String? id;
  String descricao;
  String categoria;
  double valor;
  String status;
  DateTime dataRegistro;
  DateTime diaPagamento;
  String tipo;

  Despesa({
    this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.status,
    required this.dataRegistro,
    required this.diaPagamento,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
      'status': status,
      'dataRegistro': Timestamp.fromDate(dataRegistro),
      'diaPagamento': Timestamp.fromDate(diaPagamento),
      'tipo': tipo,
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map, String id) {
    return Despesa(
      id: id,
      descricao: map['descricao'] ?? '',
      categoria: map['categoria'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      dataRegistro: (map['dataRegistro'] as Timestamp).toDate(),
      diaPagamento: (map['diaPagamento'] as Timestamp).toDate(),
      tipo: map['tipo'] ?? '',
    );
  }
}