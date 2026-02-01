import 'package:flutter/material.dart';

class VBannerPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double vDepth;
  final double vWidthFactor;

  VBannerPainter({
    required this.color,
    this.radius = 16,
    this.vDepth = 40,
    this.vWidthFactor = 0.35,
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

    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    path.lineTo(w, h - vDepth);

    path.lineTo(w / 2 + vHalfWidth, h - vDepth);

    path.lineTo(w / 2, h);

    path.lineTo(w / 2 - vHalfWidth, h - vDepth);

    path.lineTo(0, h - vDepth);
    path.lineTo(0, r);

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
