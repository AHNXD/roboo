import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';

class VideoTopNavOverlay extends StatelessWidget {
  const VideoTopNavOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(
              onTap: () => Navigator.pop(context),
              isWhite: false,
            ),
            Container(
              padding: const EdgeInsets.all(08),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Image.asset(AssetsData.programming, height: 24, width: 24),
            ),
          ],
        ),
      ),
    );
  }
}
