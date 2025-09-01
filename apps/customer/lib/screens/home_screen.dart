// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  void _goWelcome(BuildContext context) {
    // Dùng pushReplacement để quay lại Welcome như màn đầu vào
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('FoodWalk'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Header
            Text(
              'Xin chào!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đây là màn hình Home tối giản để bạn test điều hướng & hot-reload.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Dummy content
            Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Danh mục món (demo)'),
                subtitle: const Text('Chưa kết nối dữ liệu — chỉ là placeholder.'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.local_fire_department_outlined),
                title: const Text('Ưu đãi hôm nay (demo)'),
                subtitle: const Text('Placeholder để bạn test UI.'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => _goLogin(context),
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _goWelcome(context),
                icon: const Icon(Icons.celebration_outlined),
                label: const Text('Xem lại Welcome'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
