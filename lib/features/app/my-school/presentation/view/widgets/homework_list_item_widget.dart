import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/skewed_icon_widget.dart';
import 'package:roboo/features/app/my-school/data/models/homework_model.dart';
import 'package:roboo/features/app/my-school/data/models/homework_submission_model.dart';

class HomeworkListItem extends StatelessWidget {
  final HomeworkModel homework;
  final VoidCallback onTap;

  const HomeworkListItem({
    super.key,
    required this.homework,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = homework.dueDate;
    final languageCode = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SkewedIcon(
              icon: homework.type == HomeworkType.mcq
                  ? Icons.checklist_rtl
                  : Icons.edit_note,
              color: AppColors.primaryColors,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homework.titleFor(languageCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (dueDate.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 13,
                          color: homework.isOverdue
                              ? AppColors.red
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${"due_on".tr(context)} $dueDate",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: homework.isOverdue
                                ? AppColors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  _buildStatusChip(context),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final submission = homework.mySubmission;

    late final String label;
    late final Color color;

    if (submission == null) {
      label = homework.isOverdue
          ? "homework_overdue".tr(context)
          : "homework_not_submitted".tr(context);
      color = homework.isOverdue ? AppColors.red : Colors.orange;
    } else if (submission.hasVisibleScore) {
      label =
          "${"homework_score".tr(context)} ${submission.score}/${homework.maxScore ?? '-'}";
      color = AppColors.shadowGreen;
    } else if (submission.status == SubmissionStatus.missing) {
      label = "homework_not_submitted".tr(context);
      color = Colors.orange;
    } else {
      // Submitted or marked, but the teacher has not released the score yet.
      label = "homework_awaiting_mark".tr(context);
      color = AppColors.primaryTwoColors;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
