import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart'; // Import translation extension

class NewsCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String date;
  final String body;

  const NewsCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.body,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
          // Image Section
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
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 12),

          // Date
          Text(
            widget.date,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 8),

          // Title
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
            ), // Adjust padding based on direction if needed
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

          // Body (Expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              widget.body,
              maxLines: isExpanded ? null : 4,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // Read More / Less Button
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
      ),
    );
  }
}
