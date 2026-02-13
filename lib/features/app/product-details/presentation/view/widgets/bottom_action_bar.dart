import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/primary_button.dart';

class ProductBottomBar extends StatelessWidget {
  final String price;
  final VoidCallback onAddToCart;

  const ProductBottomBar({
    super.key,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PrimaryButton(
                text: "add_to_cart".tr(context),
                enterButton: true,
                mainColor: AppColors.primaryTwoColors,
                backgroundColor: AppColors.primaryColors,
                onTap: onAddToCart,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              price,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
