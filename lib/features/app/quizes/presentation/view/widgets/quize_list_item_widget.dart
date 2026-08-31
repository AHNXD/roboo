import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_icon_widget.dart';

class QuizListItem extends StatelessWidget {
  final String title;

  /// Null when the backend does not report it. `GET quizzes` omits
  /// `questions_count`, so the chip is hidden instead of showing a fake count.
  final int? questions;
  final int? duration;
  final int points;
  final bool isSolved;
  final VoidCallback onTap;

  const QuizListItem({
    super.key,
    required this.title,
    this.questions,
    this.duration,
    required this.points,
    this.isSolved = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Skewed Icon
            const SkewedIcon(),

            const SizedBox(width: 16),

            // Info Column — Expanded so a long title is ellipsised instead of
            // pushing the points off the end of the row.
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _metadata(context),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Points
            if (isSolved) ...[
              const Icon(Icons.verified, size: 16, color: Color(0xFF7FB5B7)),
              const SizedBox(width: 4),
            ],
            Text(
              "$points+ ${"points".tr(context)}",
              maxLines: 1,
              style: GoogleFonts.cairo(
                color: const Color(0xFF7FB5B7), // Light Teal
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _metadata(BuildContext context) {
    final questionsCount = questions;
    final durationMinutes = duration;

    return [
      if (questionsCount != null) ...[
        _metadataText("$questionsCount ${"questions_count".tr(context)}"),
        const SizedBox(width: 4),
        const Icon(Icons.help_outline, size: 14, color: Colors.grey),
      ],
      if (questionsCount != null && durationMinutes != null)
        const SizedBox(width: 8),
      if (durationMinutes != null) ...[
        _metadataText("$durationMinutes ${"minutes".tr(context)}"),
        const SizedBox(width: 4),
        const Icon(Icons.access_time, size: 14, color: Colors.grey),
      ],
    ];
  }

  Widget _metadataText(String value) {
    return Flexible(
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
