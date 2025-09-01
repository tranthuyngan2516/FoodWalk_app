import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FoodWalk')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // kéo là ẩn bàn phím
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Đây là trang chủ. Đăng nhập chỉ khi cần đặt/đồng bộ đơn.',
            style: TextStyle(color: Colors.black.withOpacity(0.65)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Login (khi cần)'),
          ),
          const SizedBox(height: 24),
          // demo nội dung
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_pizza_outlined),
              title: const Text('Hôm nay ăn gì?'),
              subtitle: Text('Gợi ý thực đơn theo xu hướng',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.65),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
