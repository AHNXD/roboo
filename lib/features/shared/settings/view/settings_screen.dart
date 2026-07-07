import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/go_to_button.dart';
import 'package:roboo/features/shared/settings/view/language_screen.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/settings/view/widgets/social_media_footer_widget.dart';

import '../../complaints/presentation/view/complaints_screen.dart';
import '../../faq/presentation/view/faq_screen.dart';
import '../../privacy_policy/presentation/view/privacy_policy_screen.dart';
import '../../privacy_policy/presentation/view/terms_of_use_screen.dart';

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Language
                    GoToButton(
                      title: "language".tr(context),
                      image: AssetsData.language,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const LanguageScreen(),
                        ),
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

                    const SizedBox(height: 16),

                    // Privacy Policy
                    GoToButton(
                      title: "privacy_policy_title".tr(context),
                      image: AssetsData.privacyPolicy,
                      onTap: () => Navigator.pushNamed(
                        context,
                        PrivacyPolicyScreen.routeName,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms of Use
                    GoToButton(
                      title: "terms_of_use_title".tr(context),
                      image: AssetsData.termsAndConditions,
                      onTap: () => Navigator.pushNamed(
                        context,
                        TermsOfUseScreen.routeName,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Reusable Social Footer
            const SocialMediaFooter(),
          ],
        ),
      ),
    );
  }
}
