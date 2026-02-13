import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/info_row_widget.dart';

class CourseInfoTab extends StatelessWidget {
  final bool isOnline;
  final String title;
  final bool isFav;

  const CourseInfoTab({
    super.key,
    required this.isOnline,
    required this.title,
    required this.isFav,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context),
          const SizedBox(height: 10),
          // Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CourseInfoRow(
                icon: isOnline ? Icons.public : Icons.location_on,
                text: isOnline
                    ? "online".tr(context)
                    : "in_institute".tr(context),
              ),
              CourseInfoRow(
                icon: Icons.access_time,
                text: isOnline
                    ? "20 ${"hours_suffix".tr(context)}"
                    : "20 ${"sessions_suffix".tr(context)}",
              ),
              CourseInfoRow(
                icon: Icons.quiz,
                text: "2 ${"quiz_count_suffix".tr(context)}",
              ),
              if (isOnline)
                CourseInfoRow(
                  icon: Icons.play_circle_outline,
                  text: "45 ${"video_count_suffix".tr(context)}",
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Learning Outcomes
          Text(
            "what_you_learn".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(context, "course_outcome_1"),
          _buildBulletPoint(context, "course_outcome_2"),
          _buildBulletPoint(context, "course_outcome_3"),

          const SizedBox(height: 16),

          // Age & Level
          _buildLabelColumn(
            context,
            "age_group",
            "8 - 12 ${"years".tr(context)}",
          ),

          const SizedBox(height: 16),

          _buildLevelColumn(context),

          const SizedBox(height: 16),

          // Intro Video
          Text(
            "watch_intro".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "intro_desc".tr(context),
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        FavIcon(isFav: isFav),
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              key.tr(context),
              style: GoogleFonts.cairo(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelColumn(
    BuildContext context,
    String labelKey,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr(context),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        Text(value, style: GoogleFonts.cairo(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLevelColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "level".tr(context),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              "easy".tr(context),
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(width: 4),
            HexagonWidget.pointy(
              width: 16,
              elevation: 1,
              color: AppColors.primaryColors,
            ),
            const SizedBox(width: 2),
            HexagonWidget.pointy(
              width: 16,
              elevation: 1,
              color: AppColors.primaryColors,
              child: HexagonWidget.pointy(width: 12, color: Colors.white),
            ),
            const SizedBox(width: 2),
            HexagonWidget.pointy(
              width: 16,
              elevation: 1,
              color: AppColors.primaryColors,
              child: HexagonWidget.pointy(width: 12, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
