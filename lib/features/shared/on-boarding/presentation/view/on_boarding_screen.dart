import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/features/auth/presentation/views/login/view/login_screen.dart';

import '../../../../../core/widgets/dot_background.dart';
import '../../../../../core/widgets/robot_message_bubble.dart';
import '../../../../auth/presentation/views/register/view/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),
            Column(
              children: [
                const Spacer(flex: 2),

                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    AssetsData.logo,
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                ),

                const Spacer(flex: 2),

                Hero(
                  tag: 'message_bubble',
                  child: const RobotMessageBubble(
                    message:
                        "أهلاً بك في Roboo!\nهل أنت مستعد لاكتشاف عالم البرمجة و الروبوتات؟",
                  ),
                ),

                const Spacer(flex: 3),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: "أنشئ حساب",
                        mainColor: AppColors.primaryTwoColors,
                        backgroundColor: AppColors.primaryColors,
                        imagePath: AssetsData.forwardButton,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RegisterScreen.routeName,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        withBorder: true,
                        text: "لدي حساب بالفعل",
                        mainColor: AppColors.primaryTwoColors,

                        onTap: () {
                          Navigator.pushNamed(context, LoginScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
