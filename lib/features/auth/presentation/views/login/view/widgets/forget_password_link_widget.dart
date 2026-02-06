import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class ForgotPasswordLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ForgotPasswordLink({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryColors.withValues(alpha: 0.7),
            fontSize: 14,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primaryColors.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
