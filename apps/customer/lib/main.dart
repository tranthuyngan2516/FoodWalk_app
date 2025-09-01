import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/first_run.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 BẬT 1 LẦN để xoá cờ đã xem Welcome (sau khi thấy Welcome rồi thì đổi lại false)
  const bool kForceResetFirstRunThisBoot = true; // <-- đổi về false sau khi test xong
  if (kForceResetFirstRunThisBoot) {
    // nếu muốn chỉ reset khi debug, giữ kDebugMode; còn không thì chỉ dùng cờ trên
    await FirstRunStore().reset();
  }

  runApp(const ProviderScope(child: CustomerApp()));
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodWalk - Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFF8A00), // cam sáng
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // Ẩn bàn phím khi chạm ra ngoài
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),

      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/welcome': (_) => const WelcomeScreen(),
      },

      // Màn khởi động: quyết định Welcome hay Home
      home: const _Bootstrap(),
      // home: const WelcomeScreen(devLock: true), // BẬT để luôn vào Welcome (dev)
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<bool> _firstLaunch;

  @override
  void initState() {
    super.initState();
    _firstLaunch = FirstRunStore().isFirstLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _firstLaunch,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final first = snap.data!;
        return first ? const WelcomeScreen() : const HomeScreen();
      },
    );
  }
}
