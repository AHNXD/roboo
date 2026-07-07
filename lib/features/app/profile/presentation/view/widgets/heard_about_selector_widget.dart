import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';

class HeardAboutSelector extends StatelessWidget {
  final List<String> selectedSources;
  final Function(String) onToggle;
  final bool enabled;

  const HeardAboutSelector({
    super.key,
    required this.selectedSources,
    required this.onToggle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final sources = [
      {
        'key': 'social_media',
        'label': 'source_social',
        'img': AssetsData.socialMedia,
      },
      {'key': 'family', 'label': 'source_family', 'img': AssetsData.family},
      {'key': 'friends', 'label': 'source_friends', 'img': AssetsData.friends},
      {'key': 'school', 'label': 'source_school', 'img': AssetsData.school},
      {
        'key': 'competitions',
        'label': 'source_events',
        'img': AssetsData.events,
      },
    ];

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Column(
          children: sources.map((source) {
            final key = source['key']!;
            return CustomOptionButton(
              text: source['label']!.tr(context),
              image: source['img']!,
              isRadio: false,
              isSelected: selectedSources.contains(key),
              onTap: () => onToggle(key),
            );
          }).toList(),
        ),
      ),
    );
  }
}
