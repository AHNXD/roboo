import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roboo/core/utils/colors.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const SocialIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FaIcon(icon, color: AppColors.primaryColors, size: 35),
    );
  }
}
