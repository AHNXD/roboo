import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/primary_button.dart';

class NextVideoBottomBar extends StatelessWidget {
  final String nextVideoTitle;
  final VoidCallback onNextTap;

  const NextVideoBottomBar({
    super.key,
    required this.nextVideoTitle,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Next Video Text Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "next_video_label".tr(context),
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
              Text(
                nextVideoTitle,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Next Button
          SizedBox(
            width: 120,
            child: PrimaryButton(
              text: "next_video".tr(context),
              backgroundColor: AppColors.primaryColors,
              mainColor: Colors.white,
              onTap: onNextTap,
            ),
          ),
        ],
      ),
    );
  }
}
