import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

class ComplaintInputField extends StatelessWidget {
  final TextEditingController? controller;

  const ComplaintInputField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColors.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,

        maxLines: 10,
        decoration: InputDecoration(
          hintText: "send_feedback_hint".tr(context),
          hintStyle: const TextStyle(color: Colors.black26),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
