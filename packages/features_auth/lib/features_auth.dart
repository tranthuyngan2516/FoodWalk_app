import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StateProvider<bool>((_) => false);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authStateProvider.notifier).state = true,
          child: const Text('Giả lập đăng nhập'),
        ),
      ),
    );
  }
}
