import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';

class ForgotPasswordEmailForm extends StatelessWidget {
  final TextEditingController? controller;

  const ForgotPasswordEmailForm({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: "email_hint".tr(context),
      keyboardType: TextInputType.emailAddress,
      controller: controller,
    );
  }
}
