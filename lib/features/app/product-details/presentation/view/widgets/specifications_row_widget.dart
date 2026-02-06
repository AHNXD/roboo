import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductSpecRow extends StatelessWidget {
  final String text;

  const ProductSpecRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }
}
