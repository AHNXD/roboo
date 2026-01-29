import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

import 'custom_3d_btn.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine direction for proper corner rounding
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Drawer(
      backgroundColor: Colors.white,
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
            color: AppColors.primaryColors,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 54),
            child: Image.asset(AssetsData.logo, color: Colors.white),
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
                    image: AssetsData.leaderBoard, // Use your asset path
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الألعاب",
                    image: AssetsData.games,
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الاختبارات",
                    image: AssetsData.quizes,
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    label: "الإعدادات",
                    image: AssetsData.settings,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Logout Button (MATCHING THE IMAGE) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Custom3DButton(
              text: "تسجيل الخروج",
              mainColor: AppColors.red,
              iconData: Icons.logout,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required String label,
    required String image,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(image, width: 28, height: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
