import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                AssetsData.logo,
                width: MediaQuery.of(context).size.width * 0.25,
              ),
            ),
            // Back Button (localized via Directionality usually, or fixed)
            Positioned(
              right: 0,
              top: 0,
              child: CustomBackButton(
                onTap: () => Navigator.pop(context),
                isWhite: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
