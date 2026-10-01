import 'package:flutter/material.dart';

/// Un mic ciorchine de struguri desenat (cercuri), colorat după sortiment —
/// element decorativ, nu necesită un asset imagine separat.
class GrapeBunchIcon extends StatelessWidget {
  final Color color;
  final double size;

  const GrapeBunchIcon({super.key, required this.color, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GrapeBunchPainter(color),
    );
  }
}

class _GrapeBunchPainter extends CustomPainter {
  final Color color;

  _GrapeBunchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final mainPaint = Paint()..color = color;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55);

    final r = size.width * 0.155;
    final cx = size.width * 0.5;
    final topY = size.height * 0.2;
    final positions = [
      Offset(cx - r * 1.8, topY),
      Offset(cx, topY),
      Offset(cx + r * 1.8, topY),
      Offset(cx - r * 0.9, topY + r * 1.6),
      Offset(cx + r * 0.9, topY + r * 1.6),
      Offset(cx, topY + r * 3.1),
    ];

    for (final p in positions) {
      canvas.drawCircle(p, r, Paint()..color = dark);
    }
    for (final p in positions) {
      canvas.drawCircle(p, r * 0.86, mainPaint);
      canvas.drawCircle(
        p - Offset(r * 0.28, r * 0.32),
        r * 0.26,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrapeBunchPainter oldDelegate) =>
      oldDelegate.color != color;
}
