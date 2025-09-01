import 'package:shared_preferences/shared_preferences.dart';

/// Interface lưu token
abstract class TokenStore {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}

/// Implement bằng SharedPreferences (đơn giản, chạy ổn trên iOS)
class PrefsTokenStore implements TokenStore {
  static const _kKey = 'auth_token';

  @override
  Future<void> save(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKey, token);
  }

  @override
  Future<String?> read() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kKey);
  }

  @override
  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kKey);
  }
}
