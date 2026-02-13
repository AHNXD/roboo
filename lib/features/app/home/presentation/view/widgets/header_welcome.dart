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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.primaryColors,
        shape: BubbleShapeBorder(
          side: ShapeSide.bottom,
          borderRadius: 16.toPXLength,
          arrowHeight: 40.toPXLength,
          arrowWidth: 98.toPercentLength,
          arrowCenterPosition: 50.toPercentLength,
        ),
        child: Container(
          height: 160,
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 1),
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
                  Spacer(flex: 1),
                  Image.asset(
                    AssetsData.logo,
                    color: Colors.white,

                    height: 120,
                  ),
                  Spacer(flex: 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
