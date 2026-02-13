import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class QuizOptionItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color? borderColor;
  final Color? iconColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const QuizOptionItem({
    super.key,
    required this.text,
    required this.isSelected,
    this.borderColor,
    this.iconColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color finalBorder =
        borderColor ??
        (isSelected
            ? AppColors.primaryColors
            : Colors.grey.withValues(alpha: 0.3));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: finalBorder, width: 2),
          boxShadow: (isSelected || borderColor != null)
              ? [
                  BoxShadow(
                    color: finalBorder,
                    offset: const Offset(2, 4),
                    blurRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor ?? Colors.black87,
              ),
            ),
            Icon(
              icon ??
                  (isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
              color:
                  iconColor ??
                  (isSelected ? AppColors.primaryColors : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
