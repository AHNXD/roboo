import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color mainColor;
  final Color backgroundColor;
  final IconData? iconData;
  final String? imagePath;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.mainColor = const Color(0xFFE57373),
    this.backgroundColor = Colors.white,
    this.height = 40,
    this.iconData,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = backgroundColor == Colors.white
        ? mainColor
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: mainColor,
              offset: const Offset(0, 5),
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

            if (iconData != null || imagePath != null) ...[
              SizedBox(width: 8),
              imagePath != null
                  ? Image.asset(
                      imagePath!,
                      width: 22,
                      height: 22,
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
