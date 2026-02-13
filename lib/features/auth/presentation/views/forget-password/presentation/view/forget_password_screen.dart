import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/email_form_widget.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/new_password_form_widget.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/otp_form_widget.dart';
import '../../../widgets/step_progress_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1; // 1 = Email, 2 = OTP, 3 = New Password
  final TextEditingController? passController = .new();
  final TextEditingController? confirmController = .new();
  // Getters for Dynamic Content
  String get _robotMessage {
    switch (_currentStep) {
      case 1:
        return "forgot_pass_msg_1".tr(context);
      case 2:
        return "forgot_pass_msg_2".tr(context);
      case 3:
        return "forgot_pass_msg_3".tr(context);
      default:
        return "";
    }
  }

  String get _buttonText {
    switch (_currentStep) {
      case 1:
        return "next".tr(context);
      case 2:
        return "verify_code".tr(context);
      case 3:
        return "reset_password".tr(context);
      default:
        return "";
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      } else {
        // Handle Password Reset Logic
        Navigator.pop(context);
      }
    });
  }

  void _goBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
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
                        CustomBackButton(onTap: _goBack, isWhite: true),

                        const SizedBox(width: 12),

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
                        if (_currentStep == 1) const ForgotPasswordEmailForm(),

                        // --- STEP 2: OTP ---
                        if (_currentStep == 2) ...[
                          ForgotPasswordOtpForm(
                            onSubmit: (code) {
                              // Optional: Handle auto-submit
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // --- STEP 3: NEW PASSWORD ---
                        if (_currentStep == 3)
                          ForgotPasswordNewPassForm(
                            passController: passController,
                            confirmController: confirmController,
                          ),

                        const SizedBox(height: 30),

                        // 5. Main Action Button
                        PrimaryButton(
                          text: _buttonText,
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,

                          // Only show arrow icon for first two steps
                          enterButton: _currentStep != 3 ? true : false,
                          onTap: _nextStep,
                        ),

                        // 6. Resend Timer (Only for OTP Step)
                        if (_currentStep == 2) ...[
                          const SizedBox(height: 16),
                          Text(
                            "${"resend_code".tr(context)} 00:30",
                            style: TextStyle(
                              color: AppColors.primaryColors.withValues(
                                alpha: 0.6,
                              ),
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
