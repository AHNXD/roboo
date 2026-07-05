import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';

class ComplaintsRatingRow extends StatelessWidget {
  final String profileImage;

  const ComplaintsRatingRow({super.key, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HexagonProfileAvatar(imagePath: profileImage, size: 60),
        const SizedBox(width: 20),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star_rounded,
              color: index < 4 ? const Color(0xFFFFCA28) : Colors.grey[300],
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}
