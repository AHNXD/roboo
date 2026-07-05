import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';

class ComplaintsRatingRow extends StatelessWidget {
  final String profileImage;
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const ComplaintsRatingRow({
    super.key,
    required this.profileImage,
    required this.rating,
    required this.onRatingChanged,
  });

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
            (index) => IconButton(
              onPressed: () => onRatingChanged(index + 1),
              icon: Icon(
                Icons.star_rounded,
                color: index < rating
                    ? const Color(0xFFFFCA28)
                    : Colors.grey[300],
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
