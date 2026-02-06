import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:roboo/core/utils/colors.dart';

class ForgotPasswordOtpForm extends StatelessWidget {
  final Function(String) onSubmit;

  const ForgotPasswordOtpForm({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: OtpTextField(
        numberOfFields: 4,
        showFieldAsBox: true,
        fieldWidth: 65,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        borderColor: AppColors.primaryColors.withValues(alpha: 0.5),
        focusedBorderColor: AppColors.primaryColors,
        borderWidth: 1.5,
        borderRadius: BorderRadius.circular(16),
        textStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColors,
        ),
        cursorColor: AppColors.primaryColors,
        onSubmit: onSubmit,
      ),
    );
  }
}
