import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/theme.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_orders/features_orders.dart';

void main() {
  runApp(const ProviderScope(child: DriverApp()));
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(authStateProvider);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => loggedIn ? const DriverHome() : const LoginScreen()),
        GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),
      ],
    );
    return MaterialApp.router(
      title: 'FoodWalk - Tài xế',
      theme: foodwalkLightTheme(),
      darkTheme: foodwalkDarkTheme(),
      routerConfig: router,
    );
  }
}

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FoodWalk Driver')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Đơn khả dụng'),
            subtitle: const Text('(demo placeholder)'),
            onTap: () => GoRouter.of(context).push('/orders'),
          ),
        ],
      ),
    );
  }
}
