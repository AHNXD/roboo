import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';
import 'package:roboo/features/app/leaderboard/data/models/competitor_model.dart';

class LeaderboardListItem extends StatelessWidget {
  final Competitor competitor;

  const LeaderboardListItem({super.key, required this.competitor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Highlight logic for current user
        color: competitor.isCurrentUser
            ? AppColors.primaryColors.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Rank Circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryColors,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${competitor.rank}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          HexagonProfileAvatar(
            imagePath: competitor.image,
            size: 50,
            borderColor: AppColors.primaryColors,
          ),

          const SizedBox(width: 12),

          // Name
          Text(
            competitor.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const Spacer(),

          // Points
          Text(
            "${competitor.points} ${"points".tr(context)}",
            style: TextStyle(
              color: AppColors.primaryColors.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
