import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';
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
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          HexagonProfileAvatar(imagePath: imagePath, size: 100),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryColors,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.file_upload_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
