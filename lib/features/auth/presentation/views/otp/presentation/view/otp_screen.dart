import 'package:flutter/material.dart';


import '../../../../../../../core/utils/app_localizations.dart';
import '../../../../../../../core/utils/colors.dart';
import '../../../../../../../core/utils/constats.dart';
import '../../../../../../../core/utils/styles.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import '../../../../../../../core/widgets/custom_appbar.dart';
import '../../../../../../../core/widgets/secondry_button.dart';
import '../../../confirm_password/presentation/view/confirm_password_screen.dart';

class OTPScreen extends StatelessWidget {
  static const String routeName = "/otp";
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(title: 'otp'.tr(context)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "otp_message".tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(),
                    ),
                    leading: Icon(
                      Icons.warning,
                      color: AppColors.primaryColors,
                    ),
                  ),
                  SizedBox(height: 32),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: OtpTextField(
                      onSubmit: (otp) {},
                      borderColor: AppColors.primaryColors,
                      focusedBorderColor: AppColors.primaryColors,
                      cursorColor: AppColors.primaryColors,
                      fieldWidth: size.width * 0.15,
                      showFieldAsBox: true,
                      numberOfFields: 4,
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      textStyle: Styles.textStyle18.copyWith(
                        color: AppColors.textButtonColors,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SecondryButton(
              text: 'next'.tr(context),
              onPressed: () =>
                  Navigator.pushNamed(context, ConfirmPasswordScreen.routeName),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
