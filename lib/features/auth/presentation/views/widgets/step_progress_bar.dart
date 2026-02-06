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
    double progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryColors, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColors.withValues(alpha: 0.25),
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColors,
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
      ),
    );
  }
}
