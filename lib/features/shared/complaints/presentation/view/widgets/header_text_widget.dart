import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';

class ComplaintsHeader extends StatelessWidget {
  const ComplaintsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Text(
        "complaints_desc".tr(context),
        textAlign: TextAlign.center,
        style: const TextStyle(
          height: 1.6,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
