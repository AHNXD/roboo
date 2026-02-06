import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roboo/features/shared/settings/view/widgets/social_icon_widget.dart';

class SocialMediaFooter extends StatelessWidget {
  const SocialMediaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SocialIcon(icon: FontAwesomeIcons.whatsapp),
          SizedBox(width: 20),
          SocialIcon(icon: FontAwesomeIcons.facebook),
          SizedBox(width: 20),
          SocialIcon(icon: FontAwesomeIcons.instagram),
        ],
      ),
    );
  }
}
