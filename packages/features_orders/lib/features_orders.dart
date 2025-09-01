import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: const Center(child: Text('Danh sách đơn (placeholder)')),
    );
  }
}
