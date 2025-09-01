import 'package:flutter_riverpod/flutter_riverpod.dart';

///Định nghĩa controller quản lý xem đã đăng nhập hay chưa
///Vì trước mắt chỉ cần true/false, nên ta sẽ dùng StateNotifier<bool>
///Ưu điêm của StateNotifier là có thể mở rộng về sau
/// + gom logic SignIn/SignOut vào trong 1 nơi (UI không ôm logic)
/// + Sau này muốn nâng lên User/AsyncValue<User> vẫn giữ API tương tự với UI

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false); //false nghĩa là chưa đăng nhập

  Future<void> signIn({
    required String email,
    required String password,
   }) async {
    ///Giữ logic thật đơn giản để tập trung vào luồng:
    if(email.isEmpty || password.isEmpty) {
      throw Exception('Email và mật khẩu không được để trống');
    }
    if(password.length < 6 ) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }
    //Về sau thay bằng gọi API + lưu token
    state = true; //true nghĩa là đã đăng nhập

  }
  Future<void> signOut() async {
/// Gọi logout/clear token nếu có
    state = false; //false nghĩa là chưa đăng nhập
  }
}

///Provider để UI có thể theo dõi trạng thái đăng nhập
final authStateProvider = StateNotifierProvider<AuthController, bool>((ref) => AuthController());

// Vì sao thiết kế vậy?

// StateNotifier<bool> giúp tách logic khỏi UI (dễ test, dễ thay đổi về sau).

// signIn trả Future để màn hình Rive có thể await → bắn animation checking/success/fail đúng lúc.