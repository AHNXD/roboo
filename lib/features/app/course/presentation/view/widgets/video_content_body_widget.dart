import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/course/data/models/course_quiz_model.dart';
import 'package:roboo/features/app/course/data/models/lesson_model.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_entry.dart';

class VideoContentBody extends StatelessWidget {
  final LessonModel lesson;
  final bool isWatched;
  final bool isMarkingWatched;

  /// Null once the lesson is watched — the backend has no un-watch endpoint,
  /// so the tick is final.
  final VoidCallback? onMarkWatched;

  /// Fired when the student comes back from this lesson's quiz, so the screen
  /// can re-fetch and the card stops offering a quiz that is now solved.
  final VoidCallback? onQuizClosed;

  const VideoContentBody({
    super.key,
    required this.lesson,
    this.isWatched = false,
    this.isMarkingWatched = false,
    this.onMarkWatched,
    this.onQuizClosed,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final outcomes = lesson.whatWillLearnFor(languageCode);
    final description = lesson.descriptionFor(languageCode);
    final quiz = lesson.quiz;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.titleFor(languageCode),
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${lesson.durationMinutes} ${"minutes".tr(context)}",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildWatchedControl(context),
            ],
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.cairo(color: Colors.black87, height: 1.5),
            ),
          ],

          if (outcomes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              "video_overview".tr(context),
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...outcomes.map(_buildBullet),
          ],

          if (quiz?.id != null) ...[
            const SizedBox(height: 20),
            _buildLessonQuizCard(context, quiz!, languageCode),
          ],
        ],
      ),
    );
  }

  /// The slot the mock filled with a non-functional "Download" chip. The app
  /// has no offline storage, so it carries the lesson's watched state instead:
  /// a button until the lesson is done, a plain tick afterwards.
  Widget _buildWatchedControl(BuildContext context) {
    // Preview mode: nothing to offer and nothing to report.
    if (!isWatched && onMarkWatched == null) return const SizedBox.shrink();

    if (isWatched) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              "video_watched".tr(context),
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: isMarkingWatched ? null : onMarkWatched,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColors),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMarkingWatched)
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColors,
                ),
              )
            else
              const Icon(
                Icons.check_circle_outline,
                size: 14,
                color: AppColors.primaryColors,
              ),
            const SizedBox(width: 4),
            Text(
              "mark_as_watched".tr(context),
              style: GoogleFonts.cairo(
                color: AppColors.primaryColors,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonQuizCard(
    BuildContext context,
    CourseQuizModel quiz,
    String languageCode,
  ) {
    return GestureDetector(
      onTap: () =>
          openQuizIfUnsolved(context, quizId: quiz.id, isSolved: quiz.solved),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              quiz.solved ? Icons.check_circle : Icons.description_outlined,
              color: AppColors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.solved
                        ? "quiz_completed".tr(context)
                        : "lesson_quiz".tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quiz.titleFor(languageCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text("• $text", style: GoogleFonts.cairo(color: Colors.grey[700])),
    );
  }
}
