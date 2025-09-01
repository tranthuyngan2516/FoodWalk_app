import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RiderScooterIcon extends StatefulWidget {
  const RiderScooterIcon({
    super.key,
    this.size = 76,
    this.primary = Colors.white,
    this.accent = const Color(0xFFFFE2B7),
    this.duration = const Duration(milliseconds: 1200),
    this.showSmoke = true,
    this.showHeadlight = true,
    this.showGroundShadow = true,
  });

  /// Kích thước vuông của icon.
  final double size;

  /// Màu chính (thân xe, người lái).
  final Color primary;

  /// Màu nhấn (viền sáng, đèn, highlight).
  final Color accent;

  /// Tốc độ vòng lặp animation.
  final Duration duration;

  final bool showSmoke;
  final bool showHeadlight;
  final bool showGroundShadow;

  @override
  State<RiderScooterIcon> createState() => _RiderScooterIconState();
}

class _RiderScooterIconState extends State<RiderScooterIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: Size.square(widget.size),
          painter: _RiderScooterPainter(
            t: _ctrl.value, // 0..1
            primary: widget.primary,
            accent: widget.accent,
            showSmoke: widget.showSmoke,
            showHeadlight: widget.showHeadlight,
            showGroundShadow: widget.showGroundShadow,
          ),
        ),
      ),
    );
  }
}

class _RiderScooterPainter extends CustomPainter {
  _RiderScooterPainter({
    required this.t,
    required this.primary,
    required this.accent,
    required this.showSmoke,
    required this.showHeadlight,
    required this.showGroundShadow,
  });

  final double t;
  final Color primary;
  final Color accent;
  final bool showSmoke;
  final bool showHeadlight;
  final bool showGroundShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Nhún nhẹ + hơi nghiêng thân xe cho “có hồn”.
    final bob = math.sin(t * 2 * math.pi) * (h * .03);
    final lean = math.sin((t * 2 * math.pi) + math.pi / 6) * .06; // radians
    canvas.translate(0, -bob);
    canvas.translate(w * .03, 0);
    canvas.rotate(lean);

    // Tham số chính
    final rear = Offset(w * .26, h * .78);
    final front = Offset(w * .74, h * .78);
    final rWheel = w * .16;
    final strokeW = w * .06;

    // Bút vẽ
    final stroke = Paint()
      ..color = primary.withOpacity(.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPrimary = Paint()
      ..color = primary
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1) BÓNG DƯỚI ĐẤT (rất nhẹ)
    if (showGroundShadow) {
      final ground = Paint()
        ..color = Colors.black.withOpacity(.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final shadowRect = Rect.fromCenter(
          center: Offset((rear.dx + front.dx) / 2, h * .86), width: w * .62, height: h * .10);
      canvas.drawRRect(RRect.fromRectAndRadius(shadowRect, const Radius.circular(999)), ground);
    }

    // 2) BÁNH XE (quay + glow)
    final wheelOutline = Paint()
      ..color = primary.withOpacity(.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * .95
      ..strokeCap = StrokeCap.round;

    final wheelGlow = Paint()
      ..color = accent.withOpacity(.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    void drawWheel(Offset c) {
      canvas.drawCircle(c, rWheel, wheelGlow);
      canvas.drawCircle(c, rWheel, wheelOutline);

      // Moay-ơ
      canvas.drawCircle(c, rWheel * .26, fillPrimary);

      // Nan hoa quay (3 nan)
      final ang = t * 2 * math.pi * 1.8;
      final spoke = Paint()
        ..color = primary.withOpacity(.85)
        ..strokeWidth = strokeW * .55
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final a = ang + i * (2 * math.pi / 3);
        final p = Offset(c.dx + math.cos(a) * (rWheel * .92), c.dy + math.sin(a) * (rWheel * .92));
        canvas.drawLine(c, p, spoke);
      }
    }

    drawWheel(rear);
    drawWheel(front);

    // 3) THÂN XE – gradient mềm
    final bodyPath = Path()
      ..moveTo(rear.dx - rWheel * .55, rear.dy - rWheel * .70)
      ..quadraticBezierTo(rear.dx + rWheel * .15, rear.dy - rWheel * 1.12, front.dx - rWheel * .30,
          front.dy - rWheel * .98)
      ..quadraticBezierTo(front.dx - rWheel * .05, front.dy - rWheel * 1.12,
          front.dx + rWheel * .12, front.dy - rWheel * .92);

    final bodyGradient = Paint()
      ..shader = LinearGradient(
        colors: [primary.withOpacity(.95), accent.withOpacity(.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(
        Offset(rear.dx, rear.dy - rWheel * 1.2),
        Offset(front.dx, front.dy),
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(bodyPath, bodyGradient);

    // Sàn để chân
    canvas.drawLine(
      Offset(rear.dx + rWheel * .20, rear.dy - rWheel * .18),
      Offset(front.dx - rWheel * .32, front.dy - rWheel * .25),
      stroke,
    );

    // Tay lái
    final handleStart = Offset(front.dx - rWheel * .10, front.dy - rWheel * .98);
    final handleEnd = Offset(front.dx + rWheel * .26, front.dy - rWheel * 1.20);
    canvas.drawLine(handleStart, handleEnd, stroke);

    // 4) NGƯỜI LÁI (khối + nón)
    final torso = Offset((rear.dx + front.dx) / 2 - rWheel * .18, rear.dy - rWheel * 1.34);
    final torsoRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: torso, width: rWheel * .94, height: rWheel * .72),
      Radius.circular(rWheel * .22),
    );
    // thân đổ bóng nhẹ
    final torsoShadow = Paint()
      ..color = Colors.black.withOpacity(.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(torsoRRect.shift(const Offset(0, 1.2)), torsoShadow);
    canvas.drawRRect(torsoRRect, fillPrimary);

    final head = Offset(torso.dx + rWheel * .26, torso.dy - rWheel * .58);
    canvas.drawCircle(head, rWheel * .26, fillPrimary);

    // Nón + viền sáng
    final helmet = Path()
      ..moveTo(head.dx - rWheel * .28, head.dy)
      ..quadraticBezierTo(head.dx, head.dy - rWheel * .40, head.dx + rWheel * .28, head.dy)
      ..close();
    final helmetPaint = Paint()
      ..shader = LinearGradient(
        colors: [primary, accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: head, radius: rWheel * .35));
    canvas.drawPath(helmet, helmetPaint);

    // Tay nắm tay lái
    final arm = Path()
      ..moveTo(torso.dx + rWheel * .36, torso.dy - rWheel * .12)
      ..quadraticBezierTo(
        torso.dx + rWheel * .64,
        torso.dy - rWheel * .46,
        handleEnd.dx - rWheel * .05,
        handleEnd.dy + rWheel * .04,
      );
    canvas.drawPath(arm, stroke);

    // Chân đặt lên sàn
    final leg = Path()
      ..moveTo(torso.dx - rWheel * .08, torso.dy + rWheel * .36)
      ..quadraticBezierTo(
        torso.dx + rWheel * .15,
        torso.dy + rWheel * .70,
        rear.dx + rWheel * .40,
        rear.dy - rWheel * .20,
      );
    canvas.drawPath(leg, stroke);

    // 5) ĐÈN PHA (beam mềm & lấp lánh)
    if (showHeadlight) {
      final beamStart = handleEnd;
      final beamLen = w * .55;
      final beamW = h * .24;
      final beamPath = Path()
        ..moveTo(beamStart.dx, beamStart.dy)
        ..lineTo(beamStart.dx + beamLen, beamStart.dy - beamW * .28)
        ..lineTo(beamStart.dx + beamLen, beamStart.dy + beamW * .28)
        ..close();

      final beamPaint = Paint()
        ..shader = LinearGradient(
          colors: [accent.withOpacity(.35), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(beamStart.dx, beamStart.dy - beamW / 2, beamLen, beamW))
        ..blendMode = BlendMode.plus;
      canvas.drawPath(beamPath, beamPaint);

      // tia lấp lánh nhỏ phía trước (2 hạt)
      final sparkle = Paint()..color = accent.withOpacity(.9);
      for (var i = 0; i < 2; i++) {
        final phase = (t + i * .35) % 1.0;
        final sx = beamStart.dx + beamLen * (0.3 + 0.6 * phase);
        final sy = beamStart.dy + math.sin(phase * 2 * math.pi) * (beamW * .18);
        canvas.drawCircle(Offset(sx, sy), w * .012, sparkle);
      }
    }

    // 6) KHÓI sau bánh sau (mờ dần)
    if (showSmoke) {
      final base = Offset(rear.dx - rWheel * 1.1, rear.dy - rWheel * .1);
      final puffPaint = Paint()..color = primary.withOpacity(.22);
      for (var i = 0; i < 3; i++) {
        final phase = (t + i * 0.25) % 1.0;
        final dx = -rWheel * (0.2 + phase * 0.9);
        final dy = -rWheel * (0.06 + math.sin(phase * 2 * math.pi) * 0.1);
        final r = rWheel * (0.22 + 0.18 * (1 - phase));
        canvas.drawCircle(base + Offset(dx, dy), r, puffPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RiderScooterPainter old) {
    return old.t != t ||
        old.primary != primary ||
        old.accent != accent ||
        old.showSmoke != showSmoke ||
        old.showHeadlight != showHeadlight ||
        old.showGroundShadow != showGroundShadow;
  }
}
