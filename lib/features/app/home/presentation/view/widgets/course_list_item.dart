import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 130,
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
        children: [
          SizedBox(
            width: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main Image container
                Container(
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  // Use Image.asset here instead of the placeholder
                  child: imagePlaceholder,
                ),
                // Small floating badge
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      isFav
                          ? ColorFiltered(
                              colorFilter: ColorFilter.matrix(grayscaleMatrix),
                              child: Image.asset(AssetsData.fav),
                            )
                          : Image.asset(AssetsData.fav),
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  // Metadata Row (Lectures, Time, Location)
                  Row(
                    children: [
                      _buildMeta(Icons.play_circle_outline, "$lectures فيديو"),
                      const SizedBox(width: 12),
                      _buildMeta(
                        Icons.access_time,
                        hours != null ? "$hours ساعة" : customMetadata!,
                      ),
                      const Spacer(),
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

          // Right Side: Image with Badge
        ],
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
