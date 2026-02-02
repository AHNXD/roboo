import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';

import '../../../../../../core/widgets/custome_text_field.dart';
import '../../forget-password/presentation/view/forget_password_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow resizing for keyboard
      //appBar: const CustomAppbar(title: '', showBackButton: true),
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

                  // Header: Logo and Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Image.asset(
                              AssetsData.logo,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),

                          // Back Button
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CustomBackButton(
                              onTap: () => Navigator.pop(context),
                              isWhite: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Robot Message
                  Hero(
                    tag: 'message_bubble',
                    child: const RobotMessageBubble(
                      message: "مرحباً بعودتك! لنواصل التعلم و الابتكار",
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Inputs Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Email Field
                        const CustomTextField(
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        const CustomTextField(
                          hintText: "Password",
                          obscureText: true,
                          suffixIcon: Icons.visibility_outlined,
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ForgotPasswordScreen.routeName,
                              );
                            },
                            child: Text(
                              "هل نسيت كلمة المرور؟",
                              style: TextStyle(
                                color: AppColors.primaryColors.withOpacity(0.7),
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryColors
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        PrimaryButton(
                          text: "تسجيل الدخول",
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        PrimaryButton(
                          text: "تسجيل الدخول عبر غوغل",

                          withBorder: true,
                          // Teal text
                          mainColor: AppColors.primaryColors,
                          imagePath: AssetsData.googleIcon,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ليس لديك حساب؟",
                        style: TextStyle(
                          color: AppColors.primaryColors.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "أنشئ حساب الآن",
                        style: TextStyle(
                          color: AppColors.primaryColors,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
