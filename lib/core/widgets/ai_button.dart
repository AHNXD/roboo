import 'package:flutter/material.dart';

class DiamondFab extends StatelessWidget {
  final VoidCallback onPressed;
  const DiamondFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 75, // Taller to accommodate shadow
      margin: const EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Shadow Layer (Offset downwards)
          Positioned(
            top: 8, // Push shadow down
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: 60,
                height: 60,
                color: const Color(
                  0xFF4A9192,
                ).withOpacity(0.5), // Darker teal shadow
              ),
            ),
          ),
          // 2. Main Button Layer
          GestureDetector(
            onTap: onPressed,
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF80D0C7), // Light Teal
                      Color(0xFF59A5A6), // Darker Teal
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome, // Star icon
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9E7BB5).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(old) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Simple 6-point path for a hexagon
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(old) => false;
}
