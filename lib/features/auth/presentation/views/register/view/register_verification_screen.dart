import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/main_screen.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/features/auth/presentation/view-model/register_cubit/register_cubit.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/widgets/otp_form_widget.dart';

import '../../widgets/auth_header_widget.dart';

class RegisterVerificationScreen extends StatefulWidget {
  static const String routeName = '/register-verification';

  final String email;

  const RegisterVerificationScreen({super.key, required this.email});

  @override
  State<RegisterVerificationScreen> createState() =>
      _RegisterVerificationScreenState();
}

class _RegisterVerificationScreenState
    extends State<RegisterVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendDuration = 30;

  String _code = '';
  int _secondsLeft = _resendDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
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

  void _verifyCode(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (widget.email.isEmpty) {
      messages(context, 'register_missing_email'.tr(context), Colors.red);
      return;
    }

    if (_code.length != _otpLength) {
      messages(context, 'register_code_incomplete'.tr(context), Colors.red);
      return;
    }

    context.read<RegisterCubit>().verifyAccount(
      email: widget.email,
      code: _code,
    );
  }

  void _resendCode(BuildContext context) {
    if (widget.email.isEmpty) {
      messages(context, 'register_missing_email'.tr(context), Colors.red);
      return;
    }

    context.read<RegisterCubit>().resendVerification(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(getit.get()),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is RegisterVerificationSuccess) {
            final successMessage = state.loginResponse.message.isNotEmpty
                ? state.loginResponse.message
                : 'register_account_verified';
            messages(context, successMessage.tr(context), Colors.green);
            Navigator.pushNamedAndRemoveUntil(
              context,
              MainScreen.routeName,
              (route) => false,
            );
          } else if (state is RegisterResendSuccess) {
            final resendMessage = state.message.isNotEmpty
                ? state.message
                : 'register_verification_code_sent';
            messages(context, resendMessage.tr(context), Colors.green);
            _startTimer();
          }
        },
        builder: (context, state) {
          final isVerifying = state is RegisterVerificationLoading;
          final isResending = state is RegisterResendLoading;
          final canResend = _secondsLeft == 0 && !isResending && !isVerifying;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: DotBackground()),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const AuthHeader(),
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'message_bubble',
                          child: RobotMessageBubble(
                            message: 'register_verify_email_message'.tr(
                              context,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              ForgotPasswordOtpForm(
                                numberOfFields: _otpLength,
                                fieldWidth: 46,
                                onCodeChanged: (code) => _code = code,
                                onSubmit: (code) {
                                  _code = code;
                                  _verifyCode(context);
                                },
                              ),
                              const SizedBox(height: 30),
                              if (isVerifying)
                                _LoadingButton()
                              else
                                PrimaryButton(
                                  text: 'verify_code'.tr(context),
                                  enterButton: true,
                                  backgroundColor: AppColors.primaryColors,
                                  mainColor: AppColors.primaryTwoColors,
                                  onTap: () => _verifyCode(context),
                                ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: canResend
                                    ? () => _resendCode(context)
                                    : null,
                                child: Text(
                                  isResending
                                      ? 'wait'.tr(context)
                                      : canResend
                                      ? 'resend_code'.tr(context)
                                      : '${'resend_code'.tr(context)} 00:${_secondsLeft.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: canResend
                                        ? AppColors.primaryColors
                                        : AppColors.primaryColors.withValues(
                                            alpha: 0.45,
                                          ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
