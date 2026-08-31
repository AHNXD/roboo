import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/course_favorite_button.dart';
import 'package:roboo/features/app/course/presentation/view/course_details_screen_screen.dart';

class CourseListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String categoryImage;

  /// The topic's own colour behind its icon. Null keeps the translucent white
  /// the design used before topics had colours.
  final Color? categoryColor;
  final int lectures;
  final int? hours;
  final String? customMetadata;
  final String location;
  final Color accentColor;
  final Widget imagePlaceholder;
  final IconData badgeIcon;
  final bool isOnline;
  final bool isFav;
  final String? imageUrl;
  final int? courseId;

  const CourseListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.categoryImage,
    this.categoryColor,
    required this.lectures,
    this.hours,
    this.customMetadata,
    required this.location,
    required this.accentColor,
    required this.imagePlaceholder,
    required this.badgeIcon,
    this.isOnline = true,
    this.isFav = false,
    this.imageUrl,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CourseDetailsScreen(courseId: courseId, isFav: isFav),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        constraints: const BoxConstraints(minHeight: 130),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isRtl),
            SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(isSmallScreen),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMeta(
                          Icons.play_circle_outline,
                          "$lectures ${"video".tr(context)}",
                        ),
                        _buildMeta(
                          Icons.access_time,
                          hours != null
                              ? "$hours ${"hour".tr(context)}"
                              : customMetadata!,
                        ),
                        _buildMeta(
                          isOnline
                              ? Icons.language
                              : Icons.location_on_outlined,
                          location,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        CourseFavoriteButton(courseId: courseId, initialIsFavorite: isFav),
      ],
    );
  }

  static const double _imageWidth = 110;
  static const double _imageHeight = 130;
  static const double _skew = 0.15;

  /// Skewing about the centre shifts the top and bottom edges by
  /// `skew * height / 2` in opposite directions. The counter-skewed image has
  /// to be that much wider on each side, or it cannot reach the corners of the
  /// skewed clip and the accent colour shows through as wedges.
  static const double _overscan = (_skew * _imageHeight / 2) + 1;

  Widget _buildImageSection(bool isRtl) {
    return SizedBox(
      width: _imageWidth,
      height: _imageHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            transform: Matrix4.skewX(isRtl ? -_skew : _skew),

            alignment: Alignment.center,
            child: Material(
              shape: RectangleShapeBorder(
                borderRadius: DynamicBorderRadius.all(
                  DynamicRadius.circular(20.toPXLength),
                ),
              ),
              color: accentColor,
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: _imageWidth,
                height: _imageHeight,
                // Lets the image spill past the box; the Material clips it back
                // to the skewed shape.
                child: OverflowBox(
                  maxWidth: _imageWidth + (_overscan * 2),
                  maxHeight: _imageHeight,
                  child: Transform(
                    transform: Matrix4.skewX(isRtl ? _skew : -_skew),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: _imageWidth + (_overscan * 2),
                      height: _imageHeight,
                      child: imageUrl?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => imagePlaceholder,
                              errorWidget: (context, url, error) =>
                                  imagePlaceholder,
                            )
                          : imagePlaceholder,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // No topic icon means no badge at all — an empty circle over the
          // cover reads as a missing image rather than a design element.
          if (categoryImage.trim().isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: categoryColor ?? Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: FilterChipIcon(source: categoryImage, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
