import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/enums.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/validation.dart';
import 'package:roboo/core/widgets/main_screen.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/email_form_widget.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/new_password_form_widget.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/otp_form_widget.dart';
import 'package:roboo/features/auth/presentation/view-model/reset_password_cubit/reset_password_cubit.dart';
import '../../../widgets/step_progress_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int _otpLength = 6;
  static const int _resendDuration = 30;

  int _currentStep = 1; // 1 = Email, 2 = OTP, 3 = New Password
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _code = '';
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

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

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _secondsLeft = 0);
        }
        return;
      }

      if (mounted) {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _nextStep(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_currentStep == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
      context.read<ResetPasswordCubit>().requestPasswordReset(
        email: _emailController.text.trim(),
      );
      return;
    }

    if (_currentStep == 2) {
      if (_code.length != _otpLength) {
        messages(context, "reset_code_incomplete".tr(context), Colors.red);
        return;
      }
      setState(() => _currentStep = 3);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ResetPasswordCubit>().resetPassword(
      email: _emailController.text.trim(),
      code: _code,
      password: _passController.text,
      passwordConfirmation: _confirmController.text,
    );
  }

  void _resendCode(BuildContext context) {
    if (_secondsLeft > 0) return;

    context.read<ResetPasswordCubit>().resendCode(
      email: _emailController.text.trim(),
    );
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
    return BlocProvider(
      create: (_) => ResetPasswordCubit(getit.get()),
      child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is PasswordResetCodeSent) {
            final message = state.message.isNotEmpty
                ? state.message
                : "reset_code_sent";
            messages(context, message.tr(context), Colors.green);
            setState(() => _currentStep = 2);
            _startResendTimer();
          } else if (state is ResendCodeSuccess) {
            final message = state.message.isNotEmpty
                ? state.message
                : "reset_code_sent";
            messages(context, message.tr(context), Colors.green);
            _startResendTimer();
          } else if (state is ResetPasswordSuccess) {
            final message = state.loginResponse.message.isNotEmpty
                ? state.loginResponse.message
                : "reset_password_success";
            messages(context, message.tr(context), Colors.green);
            Navigator.pushNamedAndRemoveUntil(
              context,
              MainScreen.routeName,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ResetPasswordLoading;
          final isResending = state is ResetPasswordResendLoading;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: DotBackground()),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
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

                          Hero(
                            tag: 'message_bubble',
                            child: RobotMessageBubble(message: _robotMessage),
                          ),

                          const SizedBox(height: 40),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              children: [
                                if (_currentStep == 1)
                                  ForgotPasswordEmailForm(
                                    controller: _emailController,
                                    validator: (value) => Validator.validate(
                                      value,
                                      ValidationState.email,
                                      context,
                                    ),
                                  ),

                                if (_currentStep == 2) ...[
                                  ForgotPasswordOtpForm(
                                    numberOfFields: _otpLength,
                                    fieldWidth: 46,
                                    onCodeChanged: (code) => _code = code,
                                    onSubmit: (code) {
                                      _code = code;
                                      _nextStep(context);
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                if (_currentStep == 3)
                                  ForgotPasswordNewPassForm(
                                    passController: _passController,
                                    confirmController: _confirmController,
                                    passwordValidator: (value) =>
                                        Validator.validate(
                                          value,
                                          ValidationState.password,
                                          context,
                                        ),
                                    confirmPasswordValidator: (value) =>
                                        Validator.validateConfirmPassword(
                                          value,
                                          _passController.text,
                                          context,
                                        ),
                                  ),

                                const SizedBox(height: 30),

                                if (isLoading)
                                  _LoadingButton()
                                else
                                  PrimaryButton(
                                    text: _buttonText,
                                    backgroundColor: AppColors.primaryColors,
                                    mainColor: AppColors.primaryTwoColors,
                                    enterButton: _currentStep != 3,
                                    onTap: () => _nextStep(context),
                                  ),

                                if (_currentStep == 2) ...[
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _secondsLeft == 0 && !isResending
                                        ? () => _resendCode(context)
                                        : null,
                                    child: Text(
                                      isResending
                                          ? "wait".tr(context)
                                          : _secondsLeft == 0
                                          ? "resend_code".tr(context)
                                          : "${"resend_code".tr(context)} 00:${_secondsLeft.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: AppColors.primaryColors
                                            .withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColors,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryTwoColors,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
