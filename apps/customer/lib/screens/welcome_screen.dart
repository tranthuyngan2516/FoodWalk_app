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
  static const _animDuration = Duration(seconds: 3);
  static const _holdAfter = Duration(milliseconds: 900);

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
  const _ProgressScooterBar({
    required this.progress,
    this.scooterSize = 64, // KÍCH THƯỚC ICON
    this.barHeight = 16, // ĐỘ DÀY THANH
    this.scooterOffset = 7, // NÂNG LÊN/XUỐNG (px). Dương = nâng lên
    this.lead = 0.00, // 👈 xe chạy trước 3% chiều rộng thanh
  });

  final double progress;
  final double scooterSize;
  final double barHeight;
  final double scooterOffset;
  final double lead;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final p = progress.clamp(0.0, 1.0);

      // chiều cao tổng: đủ chứa icon + một ít đệm
      final trackH = scooterSize + 24;

      // vị trí ngang (không cho icon chạm mép)
      final minX = scooterSize * 0.5;
      final maxX = w - scooterSize * 0.5;
       // 👇 cộng thêm lead để xe đi trước (có clamp để không vượt quá cuối thanh)
      final effectiveP = (p + lead).clamp(0.0, 1.0);
      final dx = (w * effectiveP).clamp(minX, maxX);

      // căn icon đúng giữa thanh rồi cộng offset người dùng
      final top = (trackH - scooterSize) / 2 - scooterOffset;

      return SizedBox(
        height: trackH,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // nền bar
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // phần đã chạy
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: barHeight,
                width: w * p,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFE2B7)],
                  ),
                ),
              ),
            ),
            // chiếc xe
           // chiếc xe
            Positioned(
              left: dx - scooterSize / 2,
              top: top,
              child: ScooterIcon(size: scooterSize), // 👈 dùng PNG của bạn
            ),
          ],
        ),
      );
    });
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
