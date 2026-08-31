import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roboo/core/utils/constats.dart';
import 'package:roboo/core/utils/external_links.dart';
import 'package:roboo/features/shared/settings/view/widgets/social_icon_widget.dart';

class SocialMediaFooter extends StatelessWidget {
  const SocialMediaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Each icon is dropped when its destination is not configured, rather than
    // sitting there doing nothing when tapped.
    final icons = <Widget>[
      if (AppContact.hasWhatsApp)
        SocialIcon(
          icon: FontAwesomeIcons.whatsapp,
          onTap: () => ExternalLinks.openWhatsApp(
            context,
            phone: AppContact.whatsAppNumber,
          ),
        ),
      if (AppContact.facebookUrl.isNotEmpty)
        SocialIcon(
          icon: FontAwesomeIcons.facebook,
          onTap: () => ExternalLinks.openUrl(context, AppContact.facebookUrl),
        ),
      if (AppContact.instagramUrl.isNotEmpty)
        SocialIcon(
          icon: FontAwesomeIcons.instagram,
          onTap: () => ExternalLinks.openUrl(context, AppContact.instagramUrl),
        ),
    ];

    if (icons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < icons.length; index++) ...[
            if (index > 0) const SizedBox(width: 20),
            icons[index],
          ],
        ],
      ),
    );
  }
}
