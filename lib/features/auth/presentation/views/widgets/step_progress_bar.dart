import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/app_localizations.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    // Safely calculate progress between 0.0 and 1.0
    double progress = totalSteps > 0
        ? (currentStep / totalSteps).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryTwoColors, AppColors.primaryColors],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "${"step".tr(context)} $currentStep ${"of".tr(context)} $totalSteps",
          style: const TextStyle(
            color: AppColors.primaryColors,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
