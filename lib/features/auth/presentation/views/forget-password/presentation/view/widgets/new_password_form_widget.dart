import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/password_textfield.dart';

class ForgotPasswordNewPassForm extends StatelessWidget {
  final TextEditingController? passController;
  final TextEditingController? confirmController;

  const ForgotPasswordNewPassForm({
    super.key,
    this.passController,
    this.confirmController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordTextField(
          hintText: "password_hint".tr(context),

          controller: passController!,
        ),
        const SizedBox(height: 16),
        PasswordTextField(
          hintText: "confirm_password".tr(context),

          controller: confirmController!,
        ),
      ],
    );
  }
}
