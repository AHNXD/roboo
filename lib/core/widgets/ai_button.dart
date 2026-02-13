import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class DiamondFab extends StatelessWidget {
  final VoidCallback onPressed;

  final Color topColor = AppColors.primaryColors;
  final Color depthColor = AppColors.primaryTwoColors;

  const DiamondFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const double size = 60.0;
    const double depth = 4.0;
    const double cornerRadius = 12.0;
    final TextDirection currentDirection = Directionality.of(context);

    return SizedBox(
      height: size + depth,
      width: size,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: depth,
            right: currentDirection == TextDirection.ltr ? depth : null,
            left: currentDirection == TextDirection.rtl ? depth : null,

            child: HexagonWidget.pointy(
              width: size,
              color: depthColor,
              cornerRadius: cornerRadius,
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onPressed,

              child: HexagonWidget.pointy(
                width: size,
                color: topColor,
                cornerRadius: cornerRadius,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(AssetsData.aiButtton, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
