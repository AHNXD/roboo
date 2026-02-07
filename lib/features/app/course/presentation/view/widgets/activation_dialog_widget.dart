import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/primary_button.dart';

class ActivationDialogs {
  static void showLocationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "locations_title".tr(context),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLocationItem("ساحة باب توما - دمشق"),
            _buildLocationItem("البرامكة - دمشق"),
            _buildLocationItem("مدارس المتفوقين - دمشق"),
            const SizedBox(height: 20),
            PrimaryButton(
              text: "ok".tr(context),
              mainColor: AppColors.primaryTwoColors,
              backgroundColor: AppColors.primaryColors,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLocationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(color: Colors.grey[700]),
      ),
    );
  }

  static void showCodeInputDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "enter_code_title".tr(context),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "code_usage_note".tr(context),
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CustomTextField(hintText: "code_hint".tr(context)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: "confirm".tr(context),
                    backgroundColor: AppColors.primaryColors,
                    mainColor: AppColors.primaryTwoColors,
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    text: "where_to_buy".tr(context),

                    mainColor: AppColors.primaryColors,

                    withBorder: true,
                    onTap: () {
                      Navigator.pop(context);
                      showLocationsDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
