import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_bar.dart';

import '../../../../../../core/utils/assets_data.dart';

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
    // Determine screen width for scaling
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // Set a minimum height instead of fixed to allow for Wrap growth
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align top for variable height
        children: [
          // Left Side: Image Stack (Fixed width usually works best for thumbnails)
          _buildImageSection(),

          // Right Side: Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
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
          // Changed from Flexible to Expanded to force space management
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
        _buildFavIcon(),
      ],
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      width: 110,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            transform: Matrix4.skewX(-0.15),
            alignment: Alignment.center,
            child: Material(
              shape: RectangleShapeBorder(
                borderRadius: DynamicBorderRadius.all(
                  DynamicRadius.circular(20.toPXLength),
                ),
              ),
              color: const Color(0xFFE55848),
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 180,
                height: 200,
                child: Transform(
                  transform: Matrix4.skewX(0.15),
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

  Widget _buildFavIcon() {
    return isFav
        ? ColorFiltered(
            colorFilter: ColorFilter.matrix(grayscaleMatrix),
            child: Image.asset(AssetsData.fav, width: 40, height: 40),
          )
        : Image.asset(AssetsData.fav, width: 40, height: 40);
  }
}
