import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class SkewedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SkewedIcon({
    super.key,
    this.icon = Icons.play_arrow_rounded,
    this.color = AppColors.primaryTwoColors,
  });

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
          color: color,
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
          child: Center(child: Icon(icon, color: Colors.white, size: 32)),
        ),
      ),
    );
  }
}
