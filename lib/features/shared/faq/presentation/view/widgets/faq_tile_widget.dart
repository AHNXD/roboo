import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;

  const FaqTile({
    super.key,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Theme(
        // Hides the default dividers of ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          iconColor: AppColors.primaryColors,
          collapsedIconColor: AppColors.primaryColors,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Question Row
          title: Row(
            children: [
              Image.asset(AssetsData.faq, width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          // Answer Body
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  answer,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
