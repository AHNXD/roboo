import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomSendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isWhite;

  const CustomSendButton({
    super.key,
    required this.onTap,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
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
        child: Image.asset(
          AssetsData.forwardButton,

          color: isWhite ? AppColors.primaryColors : Colors.white,
        ),
      ),
    );
  }
}
