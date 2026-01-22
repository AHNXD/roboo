import 'package:flutter/material.dart';
import '../../../../../../../core/utils/app_localizations.dart';
import '../../../../../../../core/utils/colors.dart';
import '../../../../../../../core/utils/enums.dart';
import '../../../../../../../core/utils/validation.dart';
import '../../../../../../../core/widgets/custom_appbar.dart';
import '../../../../../../../core/widgets/custome_text_field.dart';
import '../../../../../../../core/widgets/secondry_button.dart';
import '../../../otp/presentation/view/otp_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const String routeName = "/reset_password";
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(title: 'reset_password'.tr(context)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "reset_password_message".tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),
                    leading: Icon(
                      Icons.warning,
                      color: AppColors.primaryColors,
                    ),
                  ),
                  SizedBox(height: 32),
                  CustomTextField(
                    hintText: "email".tr(context),
                    suffixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        Validator.validate(val, ValidationState.email, context),
                  ),
                ],
              ),
            ),
            SecondryButton(
              text: 'next'.tr(context),
              onPressed: () =>
                  Navigator.pushNamed(context, OTPScreen.routeName),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
