import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isWhite;

  const CustomBackButton({
    super.key,
    required this.onTap,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Check the current language direction
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isWhite ? AppColors.primaryColors : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTwoColors,
              blurRadius: 0,
              spreadRadius: 0,

              offset: isRtl ? const Offset(-2, 3) : const Offset(2, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Transform.flip(
            flipX: isRtl ? true : false,
            child: Transform.flip(
              flipY: true,
              child: Image.asset(
                AssetsData.backButton,
                color: isWhite ? Colors.white : AppColors.primaryColors,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
