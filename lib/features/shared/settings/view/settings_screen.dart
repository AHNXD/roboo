import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/go_to_button.dart';
import 'package:roboo/features/shared/settings/view/language_screen.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/settings/view/widgets/social_media_footer_widget.dart';

import '../../complaints/presentation/view/complaints_screen.dart';
import '../../faq/presentation/view/faq_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "settings_title".tr(context)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Language
                  GoToButton(
                    title: "language".tr(context),
                    image: AssetsData.language,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const LanguageScreen()),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Complaints
                  GoToButton(
                    title: "complaints_suggestions".tr(context),
                    image: AssetsData.complaints,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const ComplaintsScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // FAQ
                  GoToButton(
                    title: "faq".tr(context),
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

            // Reusable Social Footer
            const SocialMediaFooter(),
          ],
        ),
      ),
    );
  }
}
