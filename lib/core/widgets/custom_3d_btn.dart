import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Custom3DButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color mainColor;
  final Color backgroundColor;
  final IconData? iconData;
  final String? imagePath;
  final double height;

  const Custom3DButton({
    super.key,
    required this.text,
    required this.onTap,
    this.mainColor = const Color(0xFFE57373),
    this.backgroundColor = Colors.white,
    this.height = 55,
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
          border: Border.all(color: mainColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: mainColor,
              offset: const Offset(3, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: GoogleFonts.cairo(
                color: contentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (iconData != null || imagePath != null)
              imagePath != null
                  ? Image.asset(
                      imagePath!,
                      width: 16,
                      height: 16,
                      color: contentColor,
                    )
                  : Icon(iconData, color: contentColor, size: 22),
          ],
        ),
      ),
    );
  }
}
