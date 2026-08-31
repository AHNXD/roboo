import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/widgets/full_screen_image_viewer.dart';
import 'package:roboo/core/widgets/full_screen_video_player.dart';

class NewsCard extends StatefulWidget {
  // 1. Changed from a single String to a List of Strings
  final List<String> imagePaths;

  /// Videos attached to the post. They arrive in their own `video_list`, so
  /// they sit under the image carousel rather than inside it.
  final List<String> videoPaths;
  final String title;
  final String date;
  final String body;

  const NewsCard({
    super.key,
    required this.imagePaths,
    this.videoPaths = const [],
    required this.title,
    required this.date,
    required this.body,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isExpanded = false;
  int _currentImageIndex = 0; // 3. Track the currently visible image

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = GoogleFonts.cairo(
      fontSize: 14,
      color: Colors.grey[700],
      height: 1.5,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 4. Multi-Image Section with PageView
          if (widget.imagePaths.isNotEmpty)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: PageView.builder(
                  itemCount: widget.imagePaths.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => FullScreenImageViewer.show(
                        context,
                        imageUrls: widget.imagePaths,
                        initialIndex: index,
                      ),
                      child: CustomImageWidget(
                        imageUrl: widget.imagePaths[index],
                        placeholderAsset: AssetsData.classRoom,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),
              ),
            ),

          const SizedBox(height: 8),

          if (widget.videoPaths.isNotEmpty) _buildVideos(context),

          // 5. Dots Indicator (Only shows if there is more than 1 image)
          if (widget.imagePaths.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagePaths.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppColors.primaryColors
                        : Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),
          Text(
            widget.date,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              widget.title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (context, constraints) {
              final span = TextSpan(text: widget.body, style: bodyTextStyle);
              final tp = TextPainter(
                text: span,
                maxLines: 4,
                textDirection: Directionality.of(context),
              );

              tp.layout(maxWidth: constraints.maxWidth);
              final bool isOverflowing = tp.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.body,
                      maxLines: isExpanded ? null : 4,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: bodyTextStyle,
                    ),
                  ),
                  if (isOverflowing) ...[
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded
                                ? "read_less".tr(context)
                                : "read_more".tr(context),
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF5CA4A5),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: const Color(0xFF5CA4A5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// One tile per attached video, opening it full screen. Kept separate from
  /// the image carousel: mixing a video into a `PageView` of images means it
  /// autoplays as the reader swipes past.
  Widget _buildVideos(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < widget.videoPaths.length; index++)
            GestureDetector(
              onTap: () => FullScreenVideoPlayer.show(
                context,
                url: widget.videoPaths[index],
                title: widget.title,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColors.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColors.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primaryColors,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.videoPaths.length == 1
                          ? "watch_video".tr(context)
                          : "${"watch_video".tr(context)} ${index + 1}",
                      style: GoogleFonts.cairo(
                        color: AppColors.primaryColors,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
