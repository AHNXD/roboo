import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add this package for brand icons
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/features/shared/settings/view/language_screen.dart';

import '../../complaints/presentation/view/complaints_screen.dart';
import '../../faq/presentation/view/faq_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الإعدادات"),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _SettingsTile(
                    title: "اللغة",
                    image: AssetsData.language,

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const LanguageScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    title: "الشكاوى و الاقتراحات",
                    image: AssetsData.complaints,

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const ComplaintsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    title: "الأسئلة الشائعة",
                    image: AssetsData.faq,

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const FaqScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Social Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(FontAwesomeIcons.whatsapp),
                  const SizedBox(width: 20),
                  _SocialIcon(FontAwesomeIcons.facebook),
                  const SizedBox(width: 20),
                  _SocialIcon(FontAwesomeIcons.instagram),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(image),
                const SizedBox(width: 12),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColors,
                  ),
                ),
              ],
            ),
            Image.asset(AssetsData.forwardButton, color: AppColors.cardBorder),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return FaIcon(icon, color: AppColors.primaryColors, size: 35);
  }
}
