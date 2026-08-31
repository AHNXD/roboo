import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/primary_button.dart';

/// Mirrors the course activation dialog so the two code flows feel the same.
class EnrollmentCodeDialog {
  const EnrollmentCodeDialog._();

  static void show(BuildContext context, ValueChanged<String> onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "school_code_title".tr(dialogContext),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: _EnrollmentCodeContent(onConfirm: onConfirm),
      ),
    );
  }
}

/// The controller lives in a State so it is disposed once the dialog has really
/// left the tree. Disposing it from `showDialog().then(...)` tears it down while
/// the dialog is still animating out, which throws "used after being disposed".
class _EnrollmentCodeContent extends StatefulWidget {
  final ValueChanged<String> onConfirm;

  const _EnrollmentCodeContent({required this.onConfirm});

  @override
  State<_EnrollmentCodeContent> createState() => _EnrollmentCodeContentState();
}

class _EnrollmentCodeContentState extends State<_EnrollmentCodeContent> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _confirm() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      messages(context, "this_field_is_required".tr(context), AppColors.red);
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(code);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "school_code_note".tr(context),
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: "code_hint".tr(context),
            controller: _codeController,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: "confirm".tr(context),
            backgroundColor: AppColors.primaryColors,
            mainColor: AppColors.primaryTwoColors,
            enterButton: true,
            onTap: _confirm,
          ),
        ],
      ),
    );
  }
}
