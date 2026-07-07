import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';

class ProfileAvatarEdit extends StatelessWidget {
  final String imagePath;
  final VoidCallback onEdit;

  const ProfileAvatarEdit({
    super.key,
    required this.imagePath,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: GestureDetector(
          onTap: onEdit,
          child: HexagonProfileAvatar(imagePath: imagePath),
        ),
      ),
    );
  }
}
