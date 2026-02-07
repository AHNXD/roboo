import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const CourseInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
