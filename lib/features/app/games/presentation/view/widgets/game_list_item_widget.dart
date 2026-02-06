import 'package:flutter/material.dart';
import 'package:roboo/features/app/games/presentation/view/widgets/games_icon_widget.dart';

class GameListItem extends StatelessWidget {
  final String title;
  final String duration;

  const GameListItem({super.key, required this.title, required this.duration});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkewedGameIcon(),

          const SizedBox(width: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const Spacer(),

          // Duration
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timelapse_sharp, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                duration,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
