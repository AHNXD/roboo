import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class CourseProgressBar extends StatelessWidget {
  final double progress;

  const CourseProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: AppColors.primaryTwoColors, width: 1.2),

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
              value: progress,

              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryTwoColors,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "${(progress * 100).toInt()}%",
          style: TextStyle(
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
