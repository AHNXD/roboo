import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F9), // Light Mint Background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB2DFDB), // Subtle border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Product Image ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 2. Title ---
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),

            // --- 3. Price ---
            Text(
              price,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5CA4A5), // The Teal Color
              ),
            ),

            const SizedBox(height: 10),

            // --- 4. Add to Cart Button (3D Style) ---
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Gradient for the 3D look
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF75C3C4), // Lighter Teal
                      Color(0xFF5CA4A5), // Main Teal
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF438A8B), // Darker shadow for 3D depth
                      offset: Offset(0, 3), // Pushes shadow down
                      blurRadius: 0, // Sharp shadow creates solid 3D look
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "أضف إلى السلة",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons
                          .keyboard_return, // Or shopping_cart based on icon set
                      color: Colors.white,
                      size: 18,
                      textDirection: TextDirection
                          .ltr, // Keep arrow pointing left if needed
                    ),
                  ],
                ),
              ),
            ),
            // Extra spacing for the button shadow
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
