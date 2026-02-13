import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomSendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isWhite;
  final double width;
  final double height;

  const CustomSendButton({
    super.key,
    required this.onTap,
    this.isWhite = false,
    this.width = 55,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isWhite ? Colors.white : AppColors.primaryColors,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTwoColors,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl
                ? false
                : true,
            child: Image.asset(
              AssetsData.forwardButton,

              color: isWhite ? AppColors.primaryColors : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
