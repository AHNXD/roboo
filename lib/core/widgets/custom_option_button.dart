import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final String? image;
  final bool isRadio;

  const CustomOptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.image,
    this.isRadio = false,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on selection
    final Color mainColor = isSelected
        ? AppColors.primaryColors
        : const Color(0xFFE0E0E0);
    final Color textColor = isSelected ? AppColors.primaryColors : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mainColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: mainColor,
              // Hard shadow offset exactly like Custom3DButton
              offset: const Offset(3, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (image != null) ...[
                  Image.asset(image!, height: 16, width: 16),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            Icon(
              isSelected
                  ? (isRadio ? Icons.check_circle : Icons.check_box)
                  : (isRadio
                        ? Icons.radio_button_unchecked
                        : Icons.check_box_outline_blank),
              color: mainColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
