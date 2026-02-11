import 'dart:math';

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
              color: AppColors.secColors,
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Transform.rotate(
            angle: pi,
            child: Image.asset(
              AssetsData.backButton,
              color: isWhite ? Colors.white : AppColors.primaryColors,
            ),
          ),
        ),
      ),
    );
  }
}
