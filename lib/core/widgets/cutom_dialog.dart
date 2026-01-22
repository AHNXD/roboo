import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/constats.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final String primaryButtonText;
  final String secondaryButtonText;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final IconData? icon;
  final bool? oneButton;
  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.icon,
    this.oneButton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 4,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kBorderRadius)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(kBorderRadius)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon at the top (optional)
            if (icon != null)
              Icon(
                icon,
                size: 45,
                color: primaryButtonColor ?? AppColors.primaryColors,
              ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (oneButton != null)
              if (oneButton!)
                TextButton(
                  onPressed: onSecondaryAction,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        secondaryButtonColor ?? AppColors.primaryColors,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    secondaryButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            if (oneButton == null || !oneButton!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: onSecondaryAction,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          secondaryButtonColor ?? AppColors.primaryColors,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      secondaryButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryButtonColor ?? AppColors.primaryColors,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            // Buttons
          ],
        ),
      ),
    );
  }
}
