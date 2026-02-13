import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final int points;
  final String imagePath;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.points,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HexagonProfileAvatar(imagePath: imagePath, size: 110),

        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "$points ${"points".tr(context)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColors,
          ),
        ),
      ],
    );
  }
}
