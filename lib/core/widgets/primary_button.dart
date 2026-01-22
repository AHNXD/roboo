import 'package:flutter/material.dart';

import '../utils/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColors,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: Size(screenWidth * 0.7, 55),
        elevation: 5,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown, 
        child: Text(
          text,
          maxLines: 1,
     
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
