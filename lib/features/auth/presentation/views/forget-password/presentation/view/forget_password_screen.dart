import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';

import '../../../../../../../core/widgets/custome_text_field.dart';
import '../../../widgets/step_progress_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1; // 1 = Email, 2 = OTP, 3 = New Password

  // Dynamic Content Helpers
  String get _robotMessage {
    switch (_currentStep) {
      case 1:
        return "أدخل بريدك الإلكتروني وسنرسل لك رمزاً لمساعدتك في إعادة التعيين";
      case 2:
        return "تحقق من بريدك الإلكتروني! أدخل الرمز المكون من 4 أرقام";
      case 3:
        return "اختر كلمة مرور قوية و سهلة التذكر!";
      default:
        return "";
    }
  }

  String get _buttonText {
    switch (_currentStep) {
      case 1:
        return "التالي";
      case 2:
        return "تحقق من الرمز";
      case 3:
        return "إعادة التعيين";
      default:
        return "";
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Background
            const Positioned.fill(child: DotBackground()),

            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 2. Header: Back Button & Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        // Back Button (Left side as per your code structure)
                        CustomBackButton(
                          onTap: () {
                            if (_currentStep > 1) {
                              setState(() => _currentStep--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          isWhite: true,
                        ),

                        const SizedBox(width: 12),

                        // The Progress Bar (Expanded)
                        Expanded(
                          child: StepProgressBar(
                            currentStep: _currentStep,
                            totalSteps: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. Robot Message
                  Hero(
                    tag: 'message_bubble',
                    child: RobotMessageBubble(message: _robotMessage),
                  ),

                  const SizedBox(height: 40),

                  // 4. Dynamic Body Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // --- STEP 1: EMAIL ---
                        if (_currentStep == 1) ...[
                          const CustomTextField(
                            hintText: "Email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],

                        // --- STEP 2: OTP ---
                        if (_currentStep == 2) ...[
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: OtpTextField(
                              numberOfFields: 4,
                              showFieldAsBox: true,
                              fieldWidth: 65,

                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),

                              borderColor: AppColors.primaryColors.withOpacity(
                                0.5,
                              ),
                              focusedBorderColor: AppColors.primaryColors,
                              borderWidth: 1.5,

                              borderRadius: BorderRadius.circular(16),

                              textStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColors,
                              ),

                              cursorColor: AppColors.primaryColors,

                              onSubmit: (String verificationCode) {},
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // --- STEP 3: NEW PASSWORD ---
                        if (_currentStep == 3) ...[
                          const CustomTextField(
                            hintText: "Password",
                            obscureText: true,
                            suffixIcon: Icons.visibility_outlined,
                          ),
                          const SizedBox(height: 16),
                          const CustomTextField(
                            hintText: "Confirm Password",
                            obscureText: true,
                            suffixIcon: Icons.visibility_outlined,
                          ),
                        ],

                        const SizedBox(height: 30),

                        // 5. Main Action Button
                        PrimaryButton(
                          text: _buttonText,
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,
                          imagePath: _currentStep != 3
                              ? AssetsData.forwardButton
                              : null,
                          onTap: _nextStep,
                        ),

                        // 6. Resend Timer (Only for OTP Step)
                        if (_currentStep == 2) ...[
                          const SizedBox(height: 16),
                          Text(
                            "إعادة إرسال 00:30",
                            style: TextStyle(
                              color: AppColors.primaryColors.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
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
