import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/widgets/full_screen_video_player.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/course_favorite_button.dart';
import 'package:roboo/features/app/course/data/models/course_details_model.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/info_row_widget.dart';

class CourseInfoTab extends StatelessWidget {
  final CourseDetailsModel course;
  final bool isFav;

  const CourseInfoTab({super.key, required this.course, required this.isFav});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final outcomes = course.whatWillLearnFor(languageCode);
    final ageGroup = course.ageGroup;
    final hasDemoVideo = course.demoVideoUrl?.isNotEmpty == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context, course.titleFor(languageCode)),
          const SizedBox(height: 10),
          // Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CourseInfoRow(
                icon: course.isOnline ? Icons.public : Icons.location_on,
                text: course.isOnline
                    ? "online".tr(context)
                    : "in_institute".tr(context),
              ),
              if (course.isOnline && course.durationHours != null)
                CourseInfoRow(
                  icon: Icons.access_time,
                  text: "${course.durationHours} ${"hours_suffix".tr(context)}",
                ),
              if (course.isOnline && (course.lessonsCount ?? 0) > 0)
                CourseInfoRow(
                  icon: Icons.play_circle_outline,
                  text:
                      "${course.lessonsCount} ${"video_count_suffix".tr(context)}",
                ),
              if (course.quizzes.isNotEmpty)
                CourseInfoRow(
                  icon: Icons.quiz,
                  text:
                      "${course.quizzes.length} ${"quiz_count_suffix".tr(context)}",
                ),
              if (!course.isOnline && course.sessionsCount > 0)
                CourseInfoRow(
                  icon: Icons.access_time,
                  text:
                      "${course.sessionsCount} ${"sessions_suffix".tr(context)}",
                ),
            ],
          ),

          if (outcomes.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Learning Outcomes
            Text(
              "what_you_learn".tr(context),
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...outcomes.map((outcome) => _buildBulletPoint(outcome)),
          ],

          if (ageGroup?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildLabelColumn(context, "age_group", ageGroup!),
          ],

          if (course.level?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildLevelColumn(context),
          ],

          if (hasDemoVideo) ...[
            const SizedBox(height: 16),

            // Intro Video
            Text(
              "watch_intro".tr(context),
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "intro_desc".tr(context),
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildDemoVideoThumbnail(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, String title) {
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
        CourseFavoriteButton(
          courseId: course.id,
          initialIsFavorite: course.isFavorite || isFav,
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              course.levelLabelKey.tr(context),
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(width: 4),
            ...List.generate(3, (index) {
              final isFilled = index < course.levelRank;

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 2),
                child: HexagonWidget.pointy(
                  width: 16,
                  elevation: 1,
                  color: AppColors.primaryColors,
                  child: isFilled
                      ? null
                      : HexagonWidget.pointy(width: 12, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDemoVideoThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: () => FullScreenVideoPlayer.show(
        context,
        url: course.demoVideoUrl,
        title: course.titleFor(Localizations.localeOf(context).languageCode),
        thumbnailUrl: course.demoVideoThumbnail,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The video's own poster frame when there is one; the course
              // cover is the fallback.
              CustomImageWidget(
                imageUrl: course.demoVideoThumbnail?.isNotEmpty == true
                    ? course.demoVideoThumbnail!
                    : course.imageUrl,
                placeholderAsset: AssetsData.logo,
              ),
              Container(color: Colors.black.withValues(alpha: 0.25)),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
