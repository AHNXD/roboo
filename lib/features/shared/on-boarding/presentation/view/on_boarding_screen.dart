import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/features/auth/presentation/views/login/view/login_screen.dart';
import 'package:roboo/features/auth/presentation/views/register/view/register_screen.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/on-boarding/presentation/view/widgets/action_buttons_widget.dart';
import 'package:roboo/features/shared/on-boarding/presentation/view/widgets/hero_logo_widget.dart';

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

                // 1. Logo
                const OnboardingLogo(),

                const Spacer(flex: 2),

                // 2. Robot Message
                Hero(
                  tag: 'message_bubble',
                  child: RobotMessageBubble(
                    message: "onboarding_message".tr(context),
                  ),
                ),

                const Spacer(flex: 3),

                // 3. Buttons
                OnboardingButtons(
                  onSignUp: () {
                    Navigator.pushNamed(context, RegisterScreen.routeName);
                  },
                  onLogin: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
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
