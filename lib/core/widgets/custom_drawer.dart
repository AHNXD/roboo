import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Drawer(
      backgroundColor: Colors.white,
      // 2. Adjust border radius based on side
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: isRtl ? const Radius.circular(20) : Radius.zero,
          bottomLeft: isRtl ? const Radius.circular(20) : Radius.zero,
          topRight: isRtl ? Radius.zero : const Radius.circular(20),
          bottomRight: isRtl ? Radius.zero : const Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // --- 1. Header Section ---
          Container(
            height: 240,
            width: double.infinity,
            color: AppColors.primaryColors, // The Teal color
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 54),
            child: Image.asset(
              AssetsData.logo, // Ensure you have this in AssetsData

              color: Colors.white, // Tint white if the image is black
            ),
          ),

          const SizedBox(height: 40),

          // --- 2. Menu Items ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildDrawerItem(
                    label: "لائحة المنافسين",
                    // Use Image.asset(AssetsData.trophy) here if you have images
                    icon: Icons.emoji_events,
                    iconColor: Colors.amber,
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الألعاب",
                    icon: Icons.games,
                    iconColor: Colors.purpleAccent,
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الاختبارات",
                    icon: Icons.quiz,
                    iconColor: Colors.blueAccent,
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الإعدادات",
                    icon: Icons.settings,
                    iconColor: Colors.grey,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Logout Button ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: InkWell(
              onTap: () {
                // Handle Logout Logic
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEEE), // Very light red bg
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text(
                      "تسجيل الخروج",
                      style: GoogleFonts.cairo(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Right align for Arabic
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            // Replacing standard Icon with a Container to match the "3D icon" look if needed
            Icon(icon, size: 28, color: iconColor),
          ],
        ),
      ),
    );
  }
}
