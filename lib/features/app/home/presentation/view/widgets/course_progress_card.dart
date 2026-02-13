import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/favorite_icon_widget.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_bar.dart';

class CourseProgressCard extends StatelessWidget {
  final String title;

  final String categoryImage;
  final int progressPercentage;
  final bool isFav;

  CourseProgressCard({
    super.key,
    required this.title,
    required this.categoryImage,
    required this.progressPercentage,
    this.isFav = false,
  });
  final List<double> grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
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
        FavIcon(isFav: isFav),
      ],
    );
  }

  Widget _buildImageSection(bool isRtl) {
    return SizedBox(
      width: 110,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            transform: Matrix4.skewX(isRtl ? -0.15 : 0.15),
            alignment: Alignment.center,
            child: Material(
              shape: RectangleShapeBorder(
                borderRadius: DynamicBorderRadius.all(
                  DynamicRadius.circular(20.toPXLength),
                ),
              ),
              color: AppColors.red,
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 180,
                height: 200,
                child: Transform(
                  transform: Matrix4.skewX(isRtl ? 0.15 : -0.15),
                  alignment: Alignment.center,
                  child: const Center(
                    child: Icon(Icons.coffee, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Image.asset(categoryImage, height: 16, width: 16),
            ),
          ),
        ],
      ),
    );
  }
}
