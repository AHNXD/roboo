import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';

class InterestsSelector extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(String) onToggle;
  final bool enabled;

  const InterestsSelector({
    super.key,
    required this.selectedInterests,
    required this.onToggle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Column(
          children: [
            CustomOptionButton(
              text: "filter_programming".tr(context),
              image: AssetsData.programming,
              isRadio: false,
              isSelected: selectedInterests.contains("programming"),
              onTap: () => onToggle("programming"),
            ),
            CustomOptionButton(
              text: "filter_robotics".tr(context),
              image: AssetsData.robotic,
              isRadio: false,
              isSelected: selectedInterests.contains("robotics"),
              onTap: () => onToggle("robotics"),
            ),
            CustomOptionButton(
              text: "filter_ai".tr(context),
              image: AssetsData.ai,
              isRadio: false,
              isSelected: selectedInterests.contains("ai"),
              onTap: () => onToggle("ai"),
            ),
          ],
        ),
      ),
    );
  }
}
