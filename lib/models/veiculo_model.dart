class Veiculo {
  String? id;
  String tipo;
  String marca;
  String modelo;
  String placa;
  String cor;
  String dataInstalacao;
  String diaPagamento;
  String valor;
  String idCliente;
  bool status;

  Veiculo({
    this.id,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.cor,
    required this.dataInstalacao,
    required this.diaPagamento,
    required this.valor,
    required this.idCliente,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
      'cor': cor,
      'dataInstalacao': dataInstalacao,
      'diaPagamento': diaPagamento,
      'valor': valor,
      'idCliente': idCliente,
      'status': status,
    };
  }

  factory Veiculo.fromMap(Map<String, dynamic> map, String id) {
    return Veiculo(
      id: id,
      tipo: map['tipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      placa: map['placa'],
      cor: map['cor'],
      dataInstalacao: map['dataInstalacao'],
      diaPagamento: map['diaPagamento'],
      valor: map['valor'],
      idCliente: map['idCliente'],
      status: map['status'],
    );
  }
}
