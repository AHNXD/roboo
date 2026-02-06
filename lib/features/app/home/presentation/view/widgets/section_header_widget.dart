import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

class SectionHeader extends StatelessWidget {
  final String titleKey;
  final VoidCallback onViewAll;

  const SectionHeader({
    super.key,
    required this.titleKey,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titleKey.tr(context),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              "view_all".tr(context),
              style: TextStyle(color: AppColors.primaryTwoColors),
            ),
          ),
        ],
      ),
    );
  }
}
