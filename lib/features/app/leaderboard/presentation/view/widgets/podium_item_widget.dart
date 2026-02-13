import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';
import 'package:roboo/features/app/leaderboard/data/models/competitor_model.dart';

class PodiumItem extends StatelessWidget {
  final Competitor competitor;
  final double size;
  final Color color;
  final bool isFirst;

  const PodiumItem({
    super.key,
    required this.competitor,
    required this.size,
    required this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Crown for 1st place
        if (isFirst)
          Image.asset(AssetsData.crown, height: 64, color: Color(0xFFFFCA28)),

        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            HexagonProfileAvatar(
              imagePath: competitor.image,
              size: size,
              borderColor: color,
            ),
            Transform.translate(
              offset: const Offset(0, 12),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "${competitor.rank}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          competitor.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "${competitor.points} ${"points".tr(context)}",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
