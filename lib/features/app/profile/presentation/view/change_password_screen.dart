import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/functions.dart';
import '../../../../../core/utils/services_locater.dart';
import '../../../../../core/utils/validation.dart';
import '../../../../../core/widgets/custom_appbar.dart';
import '../../../../../core/widgets/dot_background.dart';
import '../../../../../core/widgets/password_textfield.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../view-model/profile_password_cubit/profile_password_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/profile-change-password';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const int _otpLength = 6;
  static const int _resendDuration = 30;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _code = '';
  bool _codeRequested = false;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _requestCode(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<ProfilePasswordCubit>().requestPasswordUpdateCode();
  }

  void _resendCode(BuildContext context) {
    if (_secondsLeft > 0) return;
    FocusScope.of(context).unfocus();
    context.read<ProfilePasswordCubit>().resendPasswordUpdateCode();
  }

  void _updatePassword(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_code.length != _otpLength) {
      messages(
        context,
        'profile_password_code_incomplete'.tr(context),
        Colors.red,
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfilePasswordCubit>().updatePassword(
      code: _code,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfilePasswordCubit(getit.get()),
      child: BlocConsumer<ProfilePasswordCubit, ProfilePasswordState>(
        listener: (context, state) {
          if (state is ProfilePasswordError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is ProfilePasswordCodeSent) {
            final message = state.message.isNotEmpty
                ? state.message
                : 'profile_password_code_sent';
            messages(context, message.tr(context), Colors.green);
            setState(() => _codeRequested = true);
            _startResendTimer();
          } else if (state is ProfilePasswordCodeResent) {
            final message = state.message.isNotEmpty
                ? state.message
                : 'profile_password_code_sent';
            messages(context, message.tr(context), Colors.green);
            _startResendTimer();
          } else if (state is ProfilePasswordUpdateSuccess) {
            final message = state.response.message.isNotEmpty
                ? state.response.message
                : 'profile_password_success';
            messages(context, message.tr(context), Colors.green);
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfilePasswordLoading;
          final isResending = state is ProfilePasswordResendLoading;

          return Scaffold(
            appBar: CustomAppbar(title: 'change_password'.tr(context)),
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: DotBackground()),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _codeRequested
                                ? 'profile_password_update_title'.tr(context)
                                : 'profile_password_request_title'.tr(context),
                            style: GoogleFonts.cairo(
                              color: AppColors.primaryColors,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _codeRequested
                                ? 'profile_password_update_message'.tr(context)
                                : 'profile_password_request_message'.tr(
                                    context,
                                  ),
                            style: GoogleFonts.cairo(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (_codeRequested) ...[
                            _OtpFields(
                              numberOfFields: _otpLength,
                              onChanged: (code) => _code = code,
                              onSubmit: (code) => _code = code,
                            ),
                            const SizedBox(height: 24),
                            PasswordTextField(
                              hintText: 'password_hint'.tr(context),
                              controller: _passwordController,
                              validator: (value) => Validator.validate(
                                value,
                                ValidationState.password,
                                context,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PasswordTextField(
                              hintText: 'confirm_password'.tr(context),
                              controller: _confirmPasswordController,
                              validator: (value) =>
                                  Validator.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                    context,
                                  ),
                            ),
                            const SizedBox(height: 28),
                          ],
                          isLoading
                              ? const _LoadingButton()
                              : PrimaryButton(
                                  text: _codeRequested
                                      ? 'reset_password'.tr(context)
                                      : 'send_verification_code'.tr(context),
                                  backgroundColor: AppColors.primaryColors,
                                  mainColor: AppColors.primaryTwoColors,
                                  enterButton: true,
                                  onTap: () => _codeRequested
                                      ? _updatePassword(context)
                                      : _requestCode(context),
                                ),
                          if (_codeRequested) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _secondsLeft == 0 && !isResending
                                  ? () => _resendCode(context)
                                  : null,
                              child: Text(
                                isResending
                                    ? 'wait'.tr(context)
                                    : _secondsLeft == 0
                                    ? 'resend_code'.tr(context)
                                    : '${'resend_code'.tr(context)} 00:${_secondsLeft.toString().padLeft(2, '0')}',
                                style: GoogleFonts.cairo(
                                  color: AppColors.primaryColors.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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

class _OtpFields extends StatelessWidget {
  final int numberOfFields;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;

  const _OtpFields({
    required this.numberOfFields,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: OtpTextField(
        numberOfFields: numberOfFields,
        showFieldAsBox: true,
        fieldWidth: 46,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        borderColor: AppColors.primaryColors.withValues(alpha: 0.5),
        focusedBorderColor: AppColors.primaryColors,
        borderWidth: 1.5,
        borderRadius: BorderRadius.circular(16),
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColors,
        ),
        cursorColor: AppColors.primaryColors,
        onCodeChanged: onChanged,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  const _LoadingButton();

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
