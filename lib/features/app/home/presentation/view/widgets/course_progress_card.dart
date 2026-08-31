import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/course_favorite_button.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_bar.dart';

class CourseProgressCard extends StatelessWidget {
  final String title;

  final String categoryImage;

  /// The topic's own colour behind its icon. Null keeps the translucent white
  /// the design used before topics had colours.
  final Color? categoryColor;
  final int progressPercentage;
  final bool isFav;

  /// Needed for the favourite toggle; without it the heart is inert.
  final int? courseId;

  /// The course's own artwork. Falls back to a neutral icon when the backend
  /// has none.
  final String? imageUrl;

  const CourseProgressCard({
    super.key,
    required this.title,
    required this.categoryImage,
    this.categoryColor,
    required this.progressPercentage,
    this.isFav = false,
    this.courseId,
    this.imageUrl,
  });

  static const double _imageWidth = 110;
  static const double _imageHeight = 130;
  static const double _skew = 0.15;

  /// Skewing about the centre shifts the top and bottom edges apart, so the
  /// counter-skewed image has to be wider than its frame to reach the corners
  /// of the clip. Same geometry as `CourseListItem`.
  static const double _overscan = (_skew * _imageHeight / 2) + 1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
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
                  SizedBox(height: 16),
                  CourseProgressBar(progress: progressPercentage / 100),
                ],
              ),
            ),
          ),
        ],
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
              color: AppColors.primaryColors,
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: _imageWidth,
                height: _imageHeight,
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
                          ? CustomImageWidget(
                              imageUrl: imageUrl,
                              placeholderAsset: AssetsData.logo,
                            )
                          : const Center(
                              child: Icon(
                                Icons.school,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
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
}
