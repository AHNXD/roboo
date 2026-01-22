import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SecondryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;

  const SecondryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColors,
        side: const BorderSide(color: AppColors.primaryColors, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: Size(screenWidth * 0.7, 55),
        elevation: 5,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}
