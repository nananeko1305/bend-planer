import 'package:flutter/material.dart';

/// The app icon, drawn: a white microphone on a magenta-to-orange square. The
/// same drawing as `assets/icon/logo.svg`, so it stays sharp at any size and
/// keeps its colors in every look.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _MicPainter()),
      ),
    );
  }
}

class _MicPainter extends CustomPainter {
  const _MicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on the 72-unit visible part of the 108-unit adaptive icon.
    final s = size.width / 72;
    canvas.scale(s);
    canvas.translate(-18, -18);
    final rect = const Rect.fromLTWH(18, 18, 72, 72);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF2E97), Color(0xFFFF8A00)],
        ).createShader(rect),
    );
    final white = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 27, 20, 31),
        const Radius.circular(10),
      ),
      white,
    );
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(36, 31, 36, 36),
      0,
      3.14159,
      false,
      stroke,
    );
    canvas.drawLine(const Offset(54, 67), const Offset(54, 77), stroke);
    canvas.drawLine(const Offset(44, 79), const Offset(64, 79), stroke);
  }

  @override
  bool shouldRepaint(_MicPainter oldDelegate) => false;
}
