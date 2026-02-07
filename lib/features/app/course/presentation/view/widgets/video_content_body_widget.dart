import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

class VideoContentBody extends StatelessWidget {
  final String title;

  const VideoContentBody({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Download Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColors,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "download_video".tr(context),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildBullet("vid_desc_1".tr(context), isHeader: true),

          const SizedBox(height: 20),

          Text(
            "video_overview".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          _buildBullet("vid_point_1".tr(context)),
          _buildBullet("vid_point_2".tr(context)),
          _buildBullet("vid_point_3".tr(context)),
        ],
      ),
    );
  }

  Widget _buildBullet(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        isHeader ? text : "• $text",
        style: GoogleFonts.cairo(
          color: isHeader ? Colors.black87 : Colors.grey[700],
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
