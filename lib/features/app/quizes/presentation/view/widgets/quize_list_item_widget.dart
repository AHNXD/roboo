import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_icon_widget.dart';

class QuizListItem extends StatelessWidget {
  final String title;
  final int questions;
  final int duration;
  final int points;
  final VoidCallback onTap;

  const QuizListItem({
    super.key,
    required this.title,
    required this.questions,
    required this.duration,
    required this.points,
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

            // Info Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$questions ${"questions_count".tr(context)}",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.help_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$duration ${"minutes".tr(context)}",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Points
            Text(
              "$points+ ${"points".tr(context)}",
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
}
