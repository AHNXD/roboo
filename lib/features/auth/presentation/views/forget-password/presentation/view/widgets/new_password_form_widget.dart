import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/password_textfield.dart';

class ForgotPasswordNewPassForm extends StatelessWidget {
  final TextEditingController passController;
  final TextEditingController confirmController;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? confirmPasswordValidator;

  const ForgotPasswordNewPassForm({
    super.key,
    required this.passController,
    required this.confirmController,
    this.passwordValidator,
    this.confirmPasswordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordTextField(
          hintText: "password_hint".tr(context),
          controller: passController,
          validator: passwordValidator,
        ),
        const SizedBox(height: 16),
        PasswordTextField(
          hintText: "confirm_password".tr(context),
          controller: confirmController,
          validator: confirmPasswordValidator,
        ),
      ],
    );
  }
}
