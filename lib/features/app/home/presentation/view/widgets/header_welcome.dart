import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomHeaderBanner extends StatelessWidget {
  const CustomHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FullWidthVClipper(),
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        width: double.infinity,
        color: AppColors.primaryColors,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "أهلاً بك في عالم",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Roboo",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Image.asset(AssetsData.logo, color: Colors.white, height: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FullWidthVClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;

    double vDepth = 65.0;
    double borderRadius = 30.0;

    path.moveTo(0, borderRadius);

    path.quadraticBezierTo(0, 0, borderRadius, 0);

    path.lineTo(w - borderRadius, 0);

    path.quadraticBezierTo(w, 0, w, borderRadius);

    path.lineTo(w, h - vDepth);

    path.lineTo(w / 2, h);

    path.lineTo(0, h - vDepth);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
