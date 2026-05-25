import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserModel(uid: user.uid, email: user.email ?? '');
  }

  Future<UserModel?> login(String email, String senha) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return _userFromFirebase(result.user);
    } catch (e) {
      throw Exception('Erro no login: $e');
    }
  }

  Future<UserModel?> register(String email, String senha) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return _userFromFirebase(result.user);
    } catch (e) {
      throw Exception('Erro no cadastro: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}