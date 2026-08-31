import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';

/// The bar above the lesson player.
///
/// It deliberately sits *beside* the video rather than floating over it: the
/// player draws its own controls across the whole surface, and a back button
/// laid on top of them competes for the same taps.
class VideoTopNav extends StatelessWidget {
  /// Defaults to a plain pop; the player screen passes its own so the result it
  /// returns matches the system back gesture.
  final VoidCallback? onBack;

  /// The course's topic icon. Empty when the topic has no picture, and then no
  /// badge is drawn at all rather than an empty circle.
  final String topicImageUrl;

  /// The topic's colour behind that icon; null keeps the neutral default.
  final Color? topicColor;

  const VideoTopNav({
    super.key,
    this.onBack,
    this.topicImageUrl = '',
    this.topicColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasTopicIcon = topicImageUrl.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            onTap: onBack ?? () => Navigator.pop(context),
            isWhite: true,
          ),
          if (hasTopicIcon)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: topicColor ?? Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: FilterChipIcon(source: topicImageUrl, size: 24),
            ),
        ],
      ),
    );
  }
}
