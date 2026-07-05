import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';

class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final Function(String) onSelect;
  final bool enabled;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onSelect,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Row(
        children: [
          Expanded(
            child: CustomOptionButton(
              text: "female".tr(context),
              image: AssetsData.female,
              isRadio: true,
              isSelected: selectedGender == "female",
              onTap: () => onSelect("female"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomOptionButton(
              text: "male".tr(context),
              image: AssetsData.male,
              isRadio: true,
              isSelected: selectedGender == "male",
              onTap: () => onSelect("male"),
            ),
          ),
        ],
      ),
    );
  }
}
