import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

import '../../../../../../core/utils/assets_data.dart';

class CourseListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String categoryImage;
  final int lectures;
  final int? hours;
  final String? customMetadata;
  final String location;
  final Color accentColor;
  final Widget imagePlaceholder;
  final IconData badgeIcon;
  final bool isOnline;
  final bool isFav;

  CourseListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.categoryImage,
    required this.lectures,
    this.hours,
    this.customMetadata,
    required this.location,
    required this.accentColor,
    required this.imagePlaceholder,
    required this.badgeIcon,
    this.isOnline = true,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
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

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                        isOnline ? Icons.language : Icons.location_on_outlined,
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
              color: AppColors.red,
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

  Widget _buildFavIcon() {
    return isFav
        ? ColorFiltered(
            colorFilter: ColorFilter.matrix(grayscaleMatrix),
            child: Image.asset(AssetsData.fav, width: 40, height: 40),
          )
        : Image.asset(AssetsData.fav, width: 40, height: 40);
  }
}
