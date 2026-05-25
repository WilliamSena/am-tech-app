class Empresa {
  String? id;
  String nome;
  String saldo;
  String cnpj;

  Empresa({
    this.id,
    required this.nome,
    required this.saldo,
    required this.cnpj,
  });

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'saldo': saldo, 'cnpj': cnpj};
  }

  factory Empresa.fromMap(Map<String, dynamic> map, String id) {
    return Empresa(
      id: id,
      nome: map['nome'],
      saldo: map['saldo'],
      cnpj: map['cnpj'],
    );
  }
}
