import 'package:flutter/material.dart';

class VBannerPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double vDepth;
  final double vWidthFactor; // يتحكم بعرض الـ V

  VBannerPainter({
    required this.color,
    this.radius = 16,
    this.vDepth = 40,
    this.vWidthFactor = 0.35, // كل ما كبر = V أعرض
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = _buildPath(size);
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    final vHalfWidth = w * vWidthFactor / 2;

    /// ───── TOP LEFT (rounded)
    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    /// ───── RIGHT SIDE
    path.lineTo(w, h - vDepth);

    /// ───── RIGHT SLOPE (STRAIGHT)
    path.lineTo(w / 2 + vHalfWidth, h - vDepth);

    /// ───── V BOTTOM (SHARP)
    path.lineTo(w / 2, h);

    /// ───── LEFT SLOPE (STRAIGHT)
    path.lineTo(w / 2 - vHalfWidth, h - vDepth);

    /// ───── LEFT SIDE
    path.lineTo(0, h - vDepth);
    path.lineTo(0, r);

    /// ───── TOP LEFT (rounded)
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant VBannerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.vDepth != vDepth ||
        oldDelegate.vWidthFactor != vWidthFactor;
  }
}
