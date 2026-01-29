import 'package:flutter/material.dart';

class CourseProgressBar extends StatelessWidget {
  final double progress; // Value from 0.0 to 1.0 (e.g., 0.5 for 50%)

  // The specific Teal color extracted from your image
  final Color tealColor = const Color(0xFF539E9F);

  const CourseProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Progress Bar Container
        Container(
          height: 14, // Exact thickness from image
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // Pure white background track
            borderRadius: BorderRadius.circular(20), // Fully rounded pill shape
            // 1. THE BORDER: Thin teal outline around the whole bar
            border: Border.all(color: tealColor, width: 1.2),
            // 2. THE SHADOW: Soft teal glow underneath
            boxShadow: [
              BoxShadow(
                color: tealColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Clipping ensures the inner fill respects the rounded corners perfectly
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              // Transparent background so the white Container shows through
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(tealColor),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // The Percentage Text
        Text(
          "${(progress * 100).toInt()}%",
          style: TextStyle(
            color: tealColor, // Matches the bar exactly
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // Use 'Cairo' or your app's main font
            fontFamily: 'Cairo',
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
