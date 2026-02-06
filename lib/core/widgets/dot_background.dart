import 'package:flutter/material.dart';

class DotBackground extends StatelessWidget {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  const DotBackground({
    super.key,
    // Default values matching your previous code
    this.dotColor = const Color(
      0x1A9E9E9E,
    ), // Colors.grey.withValues(alpha:0.1)
    this.spacing = 30.0,
    this.dotRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    // CustomPaint with Size.infinite allows it to fill the parent
    return CustomPaint(
      size: Size.infinite,
      painter: _DotPatternPainter(
        color: dotColor,
        spacing: spacing,
        radius: dotRadius,
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  _DotPatternPainter({
    required this.color,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.radius != radius;
  }
}
