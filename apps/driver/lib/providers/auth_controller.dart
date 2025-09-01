import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((_) => PrefsTokenStore());

final authServiceProvider = Provider<AuthService>((ref) {
  final store = ref.read(tokenStoreProvider);
  return AuthService(store); // <-- đúng chữ ký constructor
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final svc = ref.read(authServiceProvider);
  return AuthController(svc)..init();
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._svc) : super(const AsyncValue.loading());
  final AuthService _svc;

  Future<void> init() async {
    try {
      final u = await _svc.tryAutoLogin();
      state = AsyncValue.data(u);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final u = await _svc.signIn(email, password);
      state = AsyncValue.data(u);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _svc.signOut();
    state = const AsyncValue.data(null);
  }
}
