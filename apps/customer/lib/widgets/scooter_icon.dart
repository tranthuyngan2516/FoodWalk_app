// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// /// Vẽ người lái + hiệu ứng trên ảnh xe PNG.
// /// - [height]: điều chỉnh chiều cao icon (muốn "cao lên" tăng số này)
// /// - [headlight], [smoke], [shadow] bật/tắt hiệu ứng
// class DeliveryScooter extends StatefulWidget {
//   const DeliveryScooter({
//     super.key,
//     this.height = 50, // ⬅ tăng lên nếu muốn icon cao hơn
//     this.assetPath = 'assets/images/scooter.png',
//     this.headlight = true,
//     this.smoke = true,
//     this.shadow = true,
//     this.loop = const Duration(milliseconds: 1400),
//   });

//   final double height;
//   final String assetPath;
//   final bool headlight;
//   final bool smoke;
//   final bool shadow;
//   final Duration loop;

//   @override
//   State<DeliveryScooter> createState() => _DeliveryScooterState();
// }

// class _DeliveryScooterState extends State<DeliveryScooter> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: widget.loop)..repeat();
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: widget.height,
//       child: AspectRatio(
//         // tỉ lệ ảnh scooter bạn gửi ~ 1.6 (ngang/rộng). Chỉnh nhẹ để “cao hơn”.
//         aspectRatio: 1.55,
//         child: AnimatedBuilder(
//           animation: _ctrl,
//           builder: (context, _) {
//             final t = _ctrl.value; // 0..1
//             final bob = math.sin(t * 2 * math.pi) * (widget.height * .04);
//             final lean = math.sin(t * 2 * math.pi + math.pi / 6) * .05; // rad

//             return Transform.translate(
//               offset: Offset(0, -bob),
//               child: Transform.rotate(
//                 angle: lean,
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // 1) Ảnh xe (thân xe PNG)
//                     Image.asset(widget.assetPath, fit: BoxFit.contain),

//                     // 2) Painter vẽ người + hiệu ứng
//                     CustomPaint(
//                       painter: _RiderFXPainter(
//                         t: t,
//                         headlight: widget.headlight,
//                         smoke: widget.smoke,
//                         shadow: widget.shadow,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// /// Vẽ người lái + đèn pha + khói + bóng dưới đất phủ lên ảnh PNG.
// class _RiderFXPainter extends CustomPainter {
//   _RiderFXPainter({
//     required this.t,
//     required this.headlight,
//     required this.smoke,
//     required this.shadow,
//   });

//   final double t;
//   final bool headlight;
//   final bool smoke;
//   final bool shadow;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width;
//     final h = size.height;

//     // Vị trí tương đối (tinh chỉnh theo PNG hiện tại)
//     final rearWheel = Offset(w * .28, h * .84);
//     final frontWheel = Offset(w * .84, h * .82);

//     // 0) Ground shadow (nhẹ)
//     if (shadow) {
//       final p = Paint()
//         ..color = Colors.black.withOpacity(.12)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
//       final rect = Rect.fromCenter(
//         center: Offset((rearWheel.dx + frontWheel.dx) / 2, h * .90),
//         width: w * .60,
//         height: h * .12,
//       );
//       canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(999)), p);
//     }

//     // 1) Người lái (tone trắng để nổi trên nền cam)
//     const primary = Colors.white;
//     final thick = w * .035;

//     // Thân người
//     final torso = Paint()..color = primary;
//     final torsoRect = RRect.fromRectAndRadius(
//       Rect.fromCenter(
//         center: Offset(w * .55, h * .45),
//         width: w * .26,
//         height: h * .18,
//       ),
//       Radius.circular(w * .06),
//     );
//     canvas.drawRRect(torsoRect, torso);

//     // Đầu + nón (nón có gradient nhẹ)
//     final head = Offset(w * .63, h * .33);
//     canvas.drawCircle(head, w * .06, Paint()..color = primary);

//     final helmet = Path()
//       ..moveTo(head.dx - w * .07, head.dy)
//       ..quadraticBezierTo(head.dx, head.dy - w * .06, head.dx + w * .07, head.dy)
//       ..close();
//     final helmetPaint = Paint()
//       ..shader = const LinearGradient(
//         colors: [Colors.white, Color(0xFFFFE2B7)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ).createShader(Rect.fromCircle(center: head, radius: w * .10));
//     canvas.drawPath(helmet, helmetPaint);

//     // Tay cầm tay lái
//     final arm = Paint()
//       ..color = primary
//       ..strokeWidth = thick
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//     canvas.drawLine(
//       Offset(w * .60, h * .42),
//       Offset(w * .78, h * .27),
//       arm,
//     );

//     // Chân đặt lên thềm xe
//     canvas.drawLine(
//       Offset(w * .52, h * .53),
//       Offset(w * .62, h * .64),
//       arm,
//     );

//     // 2) Đèn pha (beam sáng + sparkle)
//     if (headlight) {
//       final start = Offset(w * .90, h * .28);
//       final len = w * .45;
//       final spread = h * .24;
//       final beam = Path()
//         ..moveTo(start.dx, start.dy)
//         ..lineTo(start.dx + len, start.dy - spread * .25)
//         ..lineTo(start.dx + len, start.dy + spread * .25)
//         ..close();
//       final beamPaint = Paint()
//         ..shader = const LinearGradient(
//           colors: [Color(0xFFFFE2B7), Colors.transparent],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ).createShader(Rect.fromLTWH(start.dx, start.dy - spread / 2, len, spread))
//         ..blendMode = BlendMode.plus;
//       canvas.drawPath(beam, beamPaint);

//       final sparkle = Paint()..color = const Color(0xFFFFE2B7);
//       for (var i = 0; i < 2; i++) {
//         final ph = (t + i * .35) % 1;
//         final sx = start.dx + len * (0.25 + 0.6 * ph);
//         final sy = start.dy + math.sin(ph * 2 * math.pi) * (spread * .18);
//         canvas.drawCircle(Offset(sx, sy), w * .01, sparkle);
//       }
//     }

//     // 3) Khói mờ phía sau
//     if (smoke) {
//       final base = Offset(rearWheel.dx - w * .10, rearWheel.dy - h * .06);
//       final puff = Paint()..color = Colors.white.withOpacity(.22);
//       for (var i = 0; i < 3; i++) {
//         final ph = (t + i * .25) % 1;
//         final dx = -w * (.06 + .20 * ph);
//         final dy = -h * (.01 + .03 * math.sin(ph * 2 * math.pi));
//         final r = w * (.04 + .03 * (1 - ph));
//         canvas.drawCircle(base + Offset(dx, dy), r, puff);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _RiderFXPainter oldDelegate) {
//     return oldDelegate.t != t ||
//         oldDelegate.headlight != headlight ||
//         oldDelegate.smoke != smoke ||
//         oldDelegate.shadow != shadow;
//   }
// }

// lib/widgets/scooter_icon.dart
import 'package:flutter/material.dart';

class ScooterIcon extends StatelessWidget {
  const ScooterIcon({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/scooter.png', // đường dẫn PNG của bạn
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
