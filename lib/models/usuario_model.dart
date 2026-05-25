class Usuario {
  String? id;
  String login;
  String senha;
  String acesso;
  bool status;

  Usuario({
    this.id,
    required this.login,
    required this.senha,
    required this.acesso,
    required this.status,
  });

  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      login: map['login'],
      senha: map['senha'],
      acesso: map['acesso'],
      status: map['status'],
    );
  }
}