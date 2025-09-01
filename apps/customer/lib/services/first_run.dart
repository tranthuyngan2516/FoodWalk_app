import 'package:shared_preferences/shared_preferences.dart';

class FirstRunStore {
  // Đổi version key nếu muốn “reset” cho toàn bộ user khi phát hành bản mới
  static const _kSeenWelcome = 'seen_welcome_v1';

  /// true = lần đầu mở app (chưa bấm Get started)
  Future<bool> isFirstLaunch() async {
    final sp = await SharedPreferences.getInstance();
    final seen = sp.getBool(_kSeenWelcome) ?? false;
    return !seen;
  }

  /// Đánh dấu đã xem Welcome để lần sau vào thẳng Home
  Future<void> setSeen() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSeenWelcome, true);
  }

  /// (Tuỳ chọn) tiện cho debug: xóa cờ đã xem
  Future<void> reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kSeenWelcome);
  }
}
