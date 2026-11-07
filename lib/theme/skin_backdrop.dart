import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The top of the home screen, drawn per look: stage lights for Bina, a pink
/// glow on the wall for Neon, a vinyl record in the corner for Zlato.
class SkinBackdrop extends StatelessWidget {
  const SkinBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(child: CustomPaint(painter: _painterFor(c))),
          ),
        ),
        child,
      ],
    );
  }

  static CustomPainter _painterFor(AppColors c) => switch (c.skin) {
    SkinId.bina => _StagePainter(c),
    SkinId.neon => _GlowPainter(c),
    SkinId.zlato => _VinylPainter(c),
  };
}

class _StagePainter extends CustomPainter {
  _StagePainter(this.c);
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -1.3),
          radius: 1.2,
          colors: [
            c.secondary.withValues(alpha: 0.55),
            c.secondary.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
    final beams = [
      (0.18, -0.42, c.primary),
      (0.5, 0.0, const Color(0xFFA777FF)),
      (0.82, 0.42, c.tip),
    ];
    for (final (x, angle, color) in beams) {
      _beam(canvas, size, size.width * x, angle, color);
    }
  }

  void _beam(Canvas canvas, Size size, double x, double angle, Color color) {
    final length = size.height * 1.25;
    final half = length * 0.33;
    canvas.save();
    canvas.translate(x, -6);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(-5, 0)
      ..lineTo(5, 0)
      ..lineTo(half, length)
      ..lineTo(-half, length)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(-half, 0, half * 2, length)),
    );
    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StagePainter old) => old.c != c;
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.c);
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -1.1),
          radius: 1.1,
          colors: [c.primary.withValues(alpha: 0.2), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.c != c;
}

class _VinylPainter extends CustomPainter {
  _VinylPainter(this.c);
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width * 0.42, 165.0);
    final center = Offset(size.width + r * 0.18, -r * 0.2);
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF141109));
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF26221A);
    for (var g = r * 0.22; g < r; g += 3.2) {
      canvas.drawCircle(center, g, groove);
    }
    // Light catching the grooves.
    final sheen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.5
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: const [
          Colors.transparent,
          Color(0x16FFF0C8),
          Colors.transparent,
          Colors.transparent,
          Color(0x22FFF0C8),
          Colors.transparent,
        ],
        stops: const [0.05, 0.12, 0.19, 0.55, 0.62, 0.69],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r * 0.62, sheen);
    canvas.drawCircle(
      center,
      r * 0.17,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: c.heroGradient!,
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.17)),
    );
    canvas.drawCircle(center, 3, Paint()..color = c.background);
  }

  @override
  bool shouldRepaint(_VinylPainter old) => old.c != c;
}
