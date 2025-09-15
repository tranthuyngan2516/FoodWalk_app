import 'package:flutter/material.dart';
import '../services/first_run.dart';
import '../widgets/scooter_icon.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.devLock = false});
  final bool devLock;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  static const _holdAfter = Duration(milliseconds: 900);

  late final AnimationController _progressCtrl; // ✅ controller riêng cho progress 0..1
  bool _exiting = false;

  bool get _reduceMotion => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 0, // bắt đầu từ 0
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupFlow());
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // Animate mượt tới 'to' (không bao giờ tua lùi)
  Future<void> _setProgressSmooth(double to) async {
    to = to.clamp(0, 1);
    if (to <= _progressCtrl.value) return;
    final delta = to - _progressCtrl.value;

    final base = _reduceMotion ? 140 : 420; // ms cho delta = 1
    final dur = Duration(milliseconds: (base * delta).clamp(120, 600).round());

    try {
      await _progressCtrl.animateTo(
        to,
        duration: dur,
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // ignore nếu dispose giữa chừng
    }
  }

  Future<void> _runStartupFlow() async {
    try {
      await FirstRunStore().setSeen();
    } catch (_) {}

    // Thay các delay dưới bằng tác vụ thật và gọi _setProgressSmooth(...) sau mỗi bước
    await _setProgressSmooth(0.20);
    await Future.delayed(const Duration(milliseconds: 350));

    await _setProgressSmooth(0.45);
    await Future.delayed(const Duration(milliseconds: 450));

    await _setProgressSmooth(0.70);
    await Future.delayed(const Duration(milliseconds: 450));

    await _setProgressSmooth(0.90);
    await Future.delayed(const Duration(milliseconds: 400));

    await _setProgressSmooth(1.0);
    await Future.delayed(
        _reduceMotion ? const Duration(milliseconds: 150) : const Duration(milliseconds: 250));

    if (!mounted) return;
    await Future.delayed(_holdAfter);
    if (!mounted || widget.devLock) return;

    setState(() => _exiting = true);
    await Future.delayed(
        _reduceMotion ? const Duration(milliseconds: 120) : const Duration(milliseconds: 260));
    if (!mounted) return;

    // Nếu dùng GoRouter thì đổi dòng dưới thành: context.go('/home');
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);
    const orangeDark = Color(0xFFDD6F00);

    return Scaffold(
      body: AnimatedOpacity(
        opacity: _exiting ? 0.0 : 1.0,
        duration:
            _reduceMotion ? const Duration(milliseconds: 120) : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FadeSlide(
                    delay: Duration(milliseconds: 40),
                    child: Text(
                      'Chào mừng bạn 👋!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _FadeSlide(
                    delay: Duration(milliseconds: 120),
                    child: Text(
                      'Chờ một chút nhé...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),

                  const Spacer(),

                  // 🎯 Progress bar mượt theo _progressCtrl.value
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (context, _) => _ProgressScooterBar(progress: _progressCtrl.value),
                  ),

                  const Spacer(),

                  const _FadeSlide(
                    delay: Duration(milliseconds: 220),
                    from: Offset(0, .14),
                    child: _BrandLockup(),
                  ),

                  const SizedBox(height: 10),

                  // % mượt cùng controller
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (context, _) {
                        final percent = (_progressCtrl.value * 100).clamp(0, 100).round();
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, anim) {
                            final slide =
                                Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero)
                                    .animate(anim);
                            return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(position: slide, child: child));
                          },
                          child: Text(
                            '$percent%',
                            key: ValueKey(percent),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fade + slide nhẹ
class _FadeSlide extends StatelessWidget {
  const _FadeSlide({
    required this.child,
    this.delay = Duration.zero,
    this.from = const Offset(0, .10),
  });

  final Widget child;
  final Duration delay;
  final Duration duration = const Duration(milliseconds: 420);
  final Offset from;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final dur = reduce ? const Duration(milliseconds: 180) : duration;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: dur,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final dy = (1 - t) * from.dy * 40;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
      child: child,
    );
  }
}

/// Thanh progress custom + xe chạy trên thanh
class _ProgressScooterBar extends StatelessWidget {
  const _ProgressScooterBar({
    required this.progress,
  });

  final double progress;
  final double scooterSize = 36;
  final double barHeight = 12;
  final double scooterOffset = 2;
  final double lead = 0.02; // dẫn trước (0..0.1)

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final p = progress.clamp(0.0, 1.0);

      final trackH = scooterSize + 24;
      final minX = scooterSize * 0.5;
      final maxX = w - scooterSize * 0.5;

      final maxLead = (scooterSize / w).clamp(0.0, 0.1);
      final effectiveP = (p + lead.clamp(0, maxLead)).clamp(0.0, 1.0);
      final dx = (w * effectiveP).clamp(minX, maxX);

      final top = (trackH - scooterSize) / 2 - scooterOffset;

      return SizedBox(
        height: trackH,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    height: barHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE2B7)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: dx - scooterSize / 2,
              top: top,
              child: ScooterIcon(size: scooterSize),
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
    return LayoutBuilder(builder: (_, c) {
      final shader = gradient.createShader(Offset.zero & Size(c.maxWidth, style.fontSize ?? 14));
      return Text(
        text,
        style: style.copyWith(
          foreground: Paint()..shader = shader,
        ),
      );
    });
  }
}
