import 'package:flutter/material.dart';

enum CardShapeType { leftSlope, centerNotch, rightSlope }

class CardShapeClipper extends CustomClipper<Path> {
  final CardShapeType shapeType;
  final double slopeDepth;
  final double borderRadius;

  CardShapeClipper({
    required this.shapeType,
    this.slopeDepth = 50.0,
    this.borderRadius = 20.0,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;

    switch (shapeType) {
      case CardShapeType.leftSlope:
        path.moveTo(0, 0);
        path.lineTo(w, slopeDepth + 16);
        break;

      case CardShapeType.rightSlope:
        path.moveTo(0, slopeDepth + 16);
        path.lineTo(w, 0);
        break;

      case CardShapeType.centerNotch:
        path.moveTo(0, 0);
        path.lineTo(w / 2, slopeDepth);
        path.lineTo(w, 0);
        break;
    }

    path.lineTo(w, h - borderRadius);
    path.quadraticBezierTo(w, h, w - borderRadius, h);
    path.lineTo(borderRadius, h);
    path.quadraticBezierTo(0, h, 0, h - borderRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
