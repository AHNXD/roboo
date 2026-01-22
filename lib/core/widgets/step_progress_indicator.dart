import 'package:flutter/material.dart';

import '../utils/colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.activeColor = AppColors.primaryColors,
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index <= currentStep;
        bool isLast = index == totalSteps - 1;

        return Row(
          children: [
            _buildStep(index, isActive),
            if (!isLast) _buildConnector(isActive),
          ],
        );
      }),
    );
  }

  Widget _buildStep(int index, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? activeColor : inactiveColor,
    );
  }
}
