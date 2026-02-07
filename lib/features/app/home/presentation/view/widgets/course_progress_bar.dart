import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class CourseProgressBar extends StatelessWidget {
  final double progress;
  final bool inCourse;

  const CourseProgressBar({
    super.key,
    required this.progress,
    this.inCourse = false,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize progress (0.0 to 1.0) for LinearProgressIndicator
    // If you pass 60, divide by 100. If you pass 0.6, keep it.
    final double normalizedProgress = progress > 1 ? progress / 100 : progress;
    final String percentageText = "${(normalizedProgress * 100).toInt()}%";

    return inCourse
        ? Row(
            children: [
              // FIX: Wrap infinite width container in Expanded
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryTwoColors,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTwoColors.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: normalizedProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryTwoColors,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12), // Changed height to width for Row spacing

              Text(
                percentageText,
                style: const TextStyle(
                  color: AppColors.primaryTwoColors,
                  fontSize: 16, // Adjusted size slightly for row layout
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 14,
                width: double.infinity, // Safe in Column
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryTwoColors,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTwoColors.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: normalizedProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryTwoColors,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                percentageText,
                style: const TextStyle(
                  color: AppColors.primaryTwoColors,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          );
  }
}