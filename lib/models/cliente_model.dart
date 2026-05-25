class Cliente {
  String? id;
  String nome;
  String cpf;
  String email;
  bool status;

  Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'status': status,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      nome: map['nome'],
      cpf: map['cpf'],
      email: map['email'],
      status: map['status'],
    );
  }
}