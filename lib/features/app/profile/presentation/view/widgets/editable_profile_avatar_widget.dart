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
    final TextDirection direction = Directionality.of(context);

    return Center(
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: HexagonProfileAvatar(imagePath: imagePath, size: 100),
            ),

            // The Edit/Upload Button
            Positioned.directional(
              textDirection: direction,

              bottom: 4,

              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColors,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
