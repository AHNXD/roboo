import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class SkewedGameIcon extends StatelessWidget {
  const SkewedGameIcon({super.key});

  @override
  Widget build(BuildContext context) {
    const double skewAmount = -0.25;

    return Transform(
      transform: Matrix4.skewX(skewAmount),
      alignment: Alignment.center,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: AppColors.primaryTwoColors,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Transform(
          transform: Matrix4.skewX(-skewAmount),
          alignment: Alignment.center,
          child: const Center(
            child: Icon(Icons.gamepad, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
