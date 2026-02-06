import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';

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
        CustomTextField(
          hintText: "password_hint".tr(context),
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
          controller: passController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: "confirm_password".tr(context),
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
          controller: confirmController,
        ),
      ],
    );
  }
}
