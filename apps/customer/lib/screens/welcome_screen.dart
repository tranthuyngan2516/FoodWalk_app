import 'package:flutter/material.dart';
import '../services/first_run.dart';
import '../widgets/scooter_icon.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.devLock = false});
  final bool devLock; // true => KHÔNG điều hướng, ở lại Welcome để bạn chỉnh UI

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // Tổng thời gian: chạy 7s + giữ thêm 3s
  static const _animDuration = Duration(seconds: 4);
  static const _holdAfter = Duration(seconds: 1);

  late final AnimationController _ctrl;
  late final Animation<double> _progress; // 0..1

  @override
  void initState() {
    super.initState();

    // ✅ KHỞI TẠO controller + curve
    _ctrl = AnimationController(vsync: this, duration: _animDuration);
    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Khi chạy xong: setSeen (nếu không phải devLock) + điều hướng sau 3s giữ
    _ctrl.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        if (!widget.devLock) {
          try {
            await FirstRunStore().setSeen();
          } catch (_) {}
          if (!mounted) return;
          Future.delayed(_holdAfter, () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          });
        }
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
            colors: [orange, orangeDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                final p = _progress.value;
                final percent = (p * 100).round();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chào mừng bạn 👋!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chờ một chút nhé...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const Spacer(),

                    // 🎯 Thanh progress ở GIỮA + xe chạy trên thanh
                    _ProgressScooterBar(progress: p),

                    const Spacer(),

                    // 🔤 Logo/brand bên dưới
                    const _BrandLockup(),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
        final p = progress.clamp(0.0, 1.0);
        final fillW = maxW * p;

        // vị trí xe (không chạm mép)
        const minX = iconSize * 0.5;
        final maxX = maxW - iconSize * 0.5;
        final dx = (maxW * p).clamp(minX, maxX);

        return SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Nền progress
              Container(
                height: barH,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Phần đã chạy
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
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

              // Xe chạy trên thanh (căn giữa theo chiều dọc)
              Positioned(
                left: dx - iconSize / 2,
                top: (120 - iconSize) / 2, // ở giữa đúng tâm thanh
                child: const RiderScooterIcon(
                  size: 64, // khớp iconSize bạn đang dùng
                  primary: Colors.white, // icon trắng trên nền cam
                  accent: const Color(0xFFFFE2B7),
                  showSmoke: true,
                  showHeadlight: true,
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
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFE2B7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Giao nhanh • Xế xịn',
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
  }
}
