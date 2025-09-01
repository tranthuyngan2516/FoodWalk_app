import '../models/user.dart';
import 'token_store.dart';

class AuthService {
  final TokenStore _store;
  AuthService(this._store); // <-- bắt buộc truyền TokenStore

  Future<User> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900)); // giả lập API
    if (email.isEmpty || password.length < 6) {
      throw Exception('Email/mật khẩu không hợp lệ');
    }
    await _store.save('token_${DateTime.now().millisecondsSinceEpoch}');
    return User(id: 'u1', email: email);
  }

  Future<void> signOut() async => _store.clear();

  Future<User?> tryAutoLogin() async {
    final t = await _store.read();
    if (t == null) return null;
    return const User(id: 'u1', email: 'cached@user.dev');
  }
}
