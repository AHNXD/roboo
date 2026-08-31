import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/skewed_icon_widget.dart';

enum VideoStatus { locked, open, completed, downloaded, active }

class VideoChapterItem extends StatelessWidget {
  final String title;
  final int durationMinutes;
  final VideoStatus status;
  final bool isQuiz;

  /// Shows a "Free" chip. Only set for a preview the student can actually
  /// play — advertising a preview with no video uploaded is worse than not
  /// advertising one at all.
  final bool isFreePreview;

  /// The lesson's own video frame, shown in the shape the way a course card
  /// shows its cover. Quizzes and video-less lessons keep the plain icon.
  final String? imageUrl;

  final VoidCallback? onTap;

  const VideoChapterItem({
    super.key,
    required this.title,
    required this.durationMinutes,
    this.status = VideoStatus.locked,
    this.isQuiz = false,
    this.isFreePreview = false,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == VideoStatus.active;

    final Color bgColor = isActive ? AppColors.cardBg : Colors.transparent;
    final Border? border = isActive
        ? Border.all(color: AppColors.cardBorder, width: 1.5)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 85,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          children: [
            // Skewed Icon
            SkewedIcon(
              icon: isQuiz
                  ? Icons.description_outlined
                  : Icons.play_arrow_rounded,
              color: isQuiz ? AppColors.green : AppColors.primaryColors,
              imageUrl: isQuiz ? null : imageUrl,
            ),

            const SizedBox(width: 12),

            // Title & Duration
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$durationMinutes ${"minutes".tr(context)}",
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (isFreePreview) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "free_preview".tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status Icon
            _buildStatusIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case VideoStatus.active:
        return const Icon(
          Icons.download_outlined,
          color: AppColors.primaryColors,
          size: 24,
        );
      case VideoStatus.completed:
        return _buildCircleIcon(
          Icons.check,
          AppColors.primaryColors,
          Colors.white,
        );
      case VideoStatus.downloaded:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColors),
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.primaryColors,
              ),
            ),
            const SizedBox(width: 8),
            _buildCircleIcon(
              Icons.check,
              AppColors.primaryColors,
              Colors.white,
            ),
          ],
        );
      case VideoStatus.locked:
        return const Icon(Icons.lock_outline, color: Colors.grey, size: 22);
      case VideoStatus.open:
        return const Icon(
          Icons.play_circle_outline,
          color: Colors.grey,
          size: 24,
        );
    }
  }

  Widget _buildCircleIcon(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 16),
    );
  }
}
