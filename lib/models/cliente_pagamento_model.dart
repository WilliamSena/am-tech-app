class ClientePagamento {
  String? id;
  String idCliente;
  List<String> idsVeiculos;

  DateTime dataVencimento;
  DateTime? dataPagamentoRealizado;

  double valorPagar;
  double valorRecebido;

  String status; // PENDENTE, PAGO, ATRASADO

  ClientePagamento({
    this.id,
    required this.idCliente,
    required this.idsVeiculos,
    required this.dataVencimento,
    this.dataPagamentoRealizado,
    required this.valorPagar,
    required this.valorRecebido,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'idCliente': idCliente,
      'idsVeiculos': idsVeiculos,
      'dataVencimento': dataVencimento,
      'dataPagamentoRealizado': dataPagamentoRealizado,
      'valorPagar': valorPagar,
      'valorRecebido': valorRecebido,
      'status': status,
    };
  }

  factory ClientePagamento.fromMap(Map<String, dynamic> map, String id) {
    return ClientePagamento(
      id: id,
      idCliente: map['idCliente'],
      idsVeiculos: List<String>.from(map['idsVeiculos'] ?? []),
      dataVencimento: (map['dataVencimento']).toDate(),
      dataPagamentoRealizado: map['dataPagamentoRealizado']?.toDate(),
      valorPagar: (map['valorPagar'] ?? 0).toDouble(),
      valorRecebido: (map['valorRecebido'] ?? 0).toDouble(),
      status: map['status'] ?? 'PENDENTE',
    );
  }
}