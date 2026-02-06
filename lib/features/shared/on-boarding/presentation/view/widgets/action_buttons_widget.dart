import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/primary_button.dart';

class OnboardingButtons extends StatelessWidget {
  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  const OnboardingButtons({
    super.key,
    required this.onSignUp,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          PrimaryButton(
            text: "create_account".tr(context),
            mainColor: AppColors.primaryTwoColors,
            backgroundColor: AppColors.primaryColors,
            imagePath: AssetsData.forwardButton,
            onTap: onSignUp,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            withBorder: true,
            text: "onboarding_have_account".tr(context),
            mainColor: AppColors.primaryColors,
            onTap: onLogin,
          ),
        ],
      ),
    );
  }
}
