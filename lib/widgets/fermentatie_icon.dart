import 'package:flutter/material.dart';

/// Pahar plin, din care ies bule — simbolul fermentației.
class FermentatieIcon extends StatelessWidget {
  final Color color;
  final double size;

  const FermentatieIcon({super.key, required this.color, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FermentatiePainter(color),
    );
  }
}

class _FermentatiePainter extends CustomPainter {
  final Color color;

  _FermentatiePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glass = Path()
      ..moveTo(w * 0.18, h * 0.38)
      ..lineTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.72, h * 0.95)
      ..lineTo(w * 0.28, h * 0.95)
      ..close();

    final liquid = Path()
      ..moveTo(w * 0.21, h * 0.52)
      ..lineTo(w * 0.79, h * 0.52)
      ..lineTo(w * 0.72, h * 0.95)
      ..lineTo(w * 0.28, h * 0.95)
      ..close();

    canvas.drawPath(liquid, Paint()..color = color.withValues(alpha: 0.55));
    canvas.drawPath(
      glass,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06
        ..strokeJoin = StrokeJoin.round,
    );

    final bubble = Paint()..color = color;
    final bubbleLight = Paint()..color = color.withValues(alpha: 0.6);

    canvas.drawCircle(Offset(w * 0.38, h * 0.22), w * 0.07, bubble);
    canvas.drawCircle(Offset(w * 0.56, h * 0.1), w * 0.05, bubble);
    canvas.drawCircle(Offset(w * 0.66, h * 0.27), w * 0.09, bubble);
    canvas.drawCircle(Offset(w * 0.46, h * 0.66), w * 0.04, bubbleLight);
    canvas.drawCircle(Offset(w * 0.6, h * 0.78), w * 0.05, bubbleLight);
    canvas.drawCircle(Offset(w * 0.4, h * 0.8), w * 0.03, bubbleLight);
  }

  @override
  bool shouldRepaint(covariant _FermentatiePainter oldDelegate) =>
      oldDelegate.color != color;
}
