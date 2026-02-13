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
    final double normalizedProgress = (progress > 1 ? progress / 100 : progress)
        .clamp(0.0, 1.0);
    final String percentageText = "${(normalizedProgress * 100).toInt()}%";

    final Widget progressBar = Container(
      height: 16,
      width: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryTwoColors, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTwoColors,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: FractionallySizedBox(
        widthFactor: normalizedProgress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryTwoColors, AppColors.primaryColors],
            ),

            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );

    return inCourse
        ? Row(
            children: [
              Expanded(child: progressBar),
              const SizedBox(width: 12),
              Text(
                percentageText,
                style: const TextStyle(
                  color: AppColors.primaryTwoColors,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              progressBar,
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
