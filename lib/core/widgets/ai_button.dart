import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class DiamondFab extends StatelessWidget {
  final VoidCallback onPressed;

  final Color topColorLight = AppColors.primaryColors;
  final Color topColorDark = AppColors.secColors;
  final Color depthColor = const Color.fromARGB(255, 99, 148, 150);

  const DiamondFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const double size = 60;
    const double depth = 6;

    return Container(
      width: size,
      height: size + depth,
      margin: const EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: depth,

            child: ClipPath(
              clipper: RoundedHexagonClipper(),
              child: Container(width: size, height: size, color: depthColor),
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: ClipPath(
                clipper: RoundedHexagonClipper(),
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [topColorLight, topColorDark],
                    ),
                  ),

                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedHexagonClipper extends CustomClipper<Path> {
  final double radius;

  RoundedHexagonClipper({this.radius = 12.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    final double centerX = width / 2;
    final double centerY = height / 2;
    final double polyRadius = min(width, height) / 2;

    final List<double> angles = [
      -90,
      -30,
      30,
      90,
      150,
      210,
    ].map((deg) => deg * (pi / 180)).toList();

    final double r = radius;

    for (int i = 0; i < 6; i++) {
      double currentAngle = angles[i];

      if (i == 0) {
        path.moveTo(
          centerX + (polyRadius - r) * cos(currentAngle),
          centerY + (polyRadius - r) * sin(currentAngle),
        );
      }
    }

    path.reset();

    final double w = size.width;
    final double h = size.height;

    List<Offset> points = [
      Offset(w * 0.5, 0),
      Offset(w, h * 0.25),
      Offset(w, h * 0.75),
      Offset(w * 0.5, h),
      Offset(0, h * 0.75),
      Offset(0, h * 0.25),
    ];

    Offset interp(Offset p1, Offset p2, double ratio) {
      return Offset(
        p1.dx + (p2.dx - p1.dx) * ratio,
        p1.dy + (p2.dy - p1.dy) * ratio,
      );
    }

    double cornerRatio = 0.2;

    Offset start = interp(points[5], points[0], 1 - cornerRatio);
    path.moveTo(start.dx, start.dy);

    for (int i = 0; i < 6; i++) {
      Offset curr = points[i];
      Offset next = points[(i + 1) % 6];

      interp(points[i == 0 ? 5 : i - 1], curr, 1 - cornerRatio);

      Offset pAfter = interp(curr, next, cornerRatio);

      path.quadraticBezierTo(curr.dx, curr.dy, pAfter.dx, pAfter.dy);

      Offset nextPre = interp(curr, next, 1 - cornerRatio);
      path.lineTo(nextPre.dx, nextPre.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(old) => false;
}
