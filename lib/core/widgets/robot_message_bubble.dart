import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class RobotMessageBubble extends StatelessWidget {
  final String message;
  final String robotImage;

  const RobotMessageBubble({
    super.key,
    required this.message,
    this.robotImage = AssetsData.flyingRoboo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(robotImage, width: 100),
          const SizedBox(width: 12),
          Expanded(
            // WRAP WITH MATERIAL HERE
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8ECEC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Text(
                  message,

                  style: TextStyle(
                    color: AppColors.textButtonColors,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
