// lib/screens/welcome_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/first_run.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // ⏱ Điều chỉnh tổng thời gian 5–7 giây:
  static const _animDuration = Duration(seconds: 7); // chạy 0→100%
  static const _holdAfter = Duration(seconds: 3); // giữ sau khi đạt 100%

  late final AnimationController _ctrl;
  late final Animation<double> _progress; // 0..1

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _animDuration);
    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _ctrl.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        try {
          await FirstRunStore().setSeen();
        } catch (_) {}
        if (!mounted) return;
        unawaited(Future.delayed(_holdAfter, () {
          if (mounted) Navigator.of(context).pushReplacementNamed('/home');
        }));
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);
    const orangeDark = Color(0xFFDD6F00);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [orange, orangeDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chào mừng bạn trở lại 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đang chuẩn bị trải nghiệm của bạn…',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const Spacer(),

                    // 🎯 Thanh progress đặt ở GIỮA + xe chạy trên thanh
                    _ProgressScooterBar(progress: _progress.value),

                    const Spacer(),

                    // 🔤 Logo chữ FoodWalk thay cho progress ở dưới
                    const _BrandLockup(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Thanh progress custom + xe chạy trên thanh
class _ProgressScooterBar extends StatelessWidget {
  const _ProgressScooterBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    const barH = 16.0;
    const iconSize = 64.0;

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final clamped = progress.clamp(0.0, 1.0);
        final fillW = maxW * clamped;

        // vị trí xe (để không “thò” ra ngoài)
        const minX = iconSize * 0.5;
        final maxX = maxW - iconSize * 0.5;
        final dx = (maxW * clamped).clamp(minX, maxX);

        return SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Thanh nền
              Container(
                height: barH,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Thanh đã fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: fillW,
                height: barH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFE2B7)],
                  ),
                ),
              ),

              // Xe chạy — đặt CHỒNG LÊN thanh (nằm trên thanh)
              Positioned(
                left: dx - iconSize / 2,
                // hạ icon xuống để “đè” đúng lên thanh
                top: (120 - barH) / 2 - (iconSize / 2) + 6,
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Logo chữ “FoodWalk” kiểu gradient + tagline
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          'FoodWalk',
          style:  TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          gradient:  LinearGradient(
            colors: [Colors.white, Color(0xFFFFE2B7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
         SizedBox(height: 6),
         Text(
          'Giao nhanh • Tươi ngon',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style, required this.gradient});
  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
    // (tùy chọn) có thể thêm shadow nếu muốn nổi hơn.
  }
}
