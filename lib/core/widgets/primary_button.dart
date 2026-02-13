import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color mainColor;
  final Color backgroundColor;
  final IconData? iconData;
  final String? imagePath;
  final double height;
  final bool withBorder;
  final bool enterButton;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.mainColor = const Color(0xFFE57373),
    this.backgroundColor = Colors.white,
    this.height = 40,
    this.iconData,
    this.imagePath,
    this.withBorder = false,
    this.enterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = backgroundColor == Colors.white
        ? mainColor
        : Colors.white;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: withBorder ? Border.all(color: mainColor, width: 1) : null,
          boxShadow: [
            BoxShadow(
              color: mainColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.cairo(
                color: contentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (iconData != null || imagePath != null || enterButton) ...[
              SizedBox(width: 8),
              enterButton == true
                  ? Transform.flip(
                      flipX: isRtl ? false : true,
                      child: Image.asset(
                        AssetsData.forwardButton,
                        width: 16,
                        height: 16,
                        color: contentColor,
                      ),
                    )
                  : imagePath != null
                  ? Image.asset(
                      imagePath!,
                      width: 16,
                      height: 16,
                      color: contentColor,
                    )
                  : Icon(iconData, color: contentColor, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}
