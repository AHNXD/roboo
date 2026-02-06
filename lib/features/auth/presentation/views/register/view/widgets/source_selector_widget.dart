import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';

class RegisterSourceSelector extends StatelessWidget {
  final List<String> selectedSources;
  final Function(String) onToggle;

  const RegisterSourceSelector({
    super.key,
    required this.selectedSources,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // List of sources with their keys and assets
    final sources = [
      {
        'key': 'social',
        'label': 'source_social',
        'img': AssetsData.socialMedia,
      },
      {'key': 'family', 'label': 'source_family', 'img': AssetsData.family},
      {'key': 'friends', 'label': 'source_friends', 'img': AssetsData.friends},
      {'key': 'school', 'label': 'source_school', 'img': AssetsData.school},
      {'key': 'events', 'label': 'source_events', 'img': AssetsData.events},
    ];

    return Column(
      children: sources.map((source) {
        final key = source['key']!;
        return CustomOptionButton(
          text: (source['label']!).tr(context),
          image: source['img']!,
          isRadio: false,
          isSelected: selectedSources.contains(key),
          onTap: () => onToggle(key),
        );
      }).toList(),
    );
  }
}
