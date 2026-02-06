import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomHeaderBanner extends StatelessWidget {
  const CustomHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.primaryColors,
        shape: BubbleShapeBorder(
          side: ShapeSide.bottom,
          borderRadius: 8.toPXLength,
          arrowHeight: 60.toPXLength,
          arrowWidth: 100.toPercentLength,
          arrowCenterPosition: 50.toPercentLength,
        ),
        child: Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "welcome_world".tr(context),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
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
                  Image.asset(
                    AssetsData.logo,
                    color: Colors.white,
                    height: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
