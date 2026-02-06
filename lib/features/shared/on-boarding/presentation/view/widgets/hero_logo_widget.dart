import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';

class OnboardingLogo extends StatelessWidget {
  const OnboardingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Image.asset(
        AssetsData.logo,
        width: MediaQuery.of(context).size.width * 0.25,
      ),
    );
  }
}
