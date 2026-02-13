import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class GoToButton extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const GoToButton({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(image, height: 32),
                const SizedBox(width: 12),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColors,
                  ),
                ),
              ],
            ),
            Transform.flip(
              flipX: isRtl ? false : true,
              child: Image.asset(
                AssetsData.forwardButton,
                color: AppColors.cardBorder,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
