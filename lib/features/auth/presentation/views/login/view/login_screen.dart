import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/main_screen.dart';
import 'package:roboo/core/widgets/password_textfield.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/presentation/views/login/view/widgets/forget_password_link_widget.dart';
import 'package:roboo/features/auth/presentation/views/register/view/register_screen.dart';
import '../../../../../../core/widgets/custome_text_field.dart';
import '../../forget-password/presentation/view/forget_password_screen.dart';
import '../../widgets/auth_footer_widget.dart';
import '../../widgets/auth_header_widget.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  LoginScreen({super.key});
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Reusable Dot Background
            const Positioned.fill(child: DotBackground()),

            // 2. Main Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  const AuthHeader(),

                  const SizedBox(height: 30),

                  // Robot Message
                  Hero(
                    tag: 'message_bubble',
                    child: RobotMessageBubble(
                      message: "login_welcome".tr(context),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Inputs Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Email Field
                        CustomTextField(
                          hintText: "email_hint".tr(context),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        PasswordTextField(
                          hintText: "password_hint".tr(context),
                          controller: passwordController,
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password Link
                        ForgotPasswordLink(
                          text: "forgot_password".tr(context),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ForgotPasswordScreen.routeName,
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        PrimaryButton(
                          text: "login_btn".tr(context),
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              MainScreen.routeName,
                              (route) => false,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Google Login Button
                        PrimaryButton(
                          text: "google_login".tr(context),
                          withBorder: true,
                          mainColor: AppColors.primaryColors,
                          imagePath: AssetsData.googleIcon,
                          onTap: () {
                            // Handle Google Login
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer Text
                  AuthFooter(
                    text: "no_account".tr(context),
                    actionText: "create_account_now".tr(context),
                    onTap: () {
                      Navigator.pushNamed(context, RegisterScreen.routeName);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
