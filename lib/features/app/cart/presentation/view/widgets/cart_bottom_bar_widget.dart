import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/primary_button.dart';

class CartBottomBar extends StatelessWidget {
  final String totalPrice;
  final bool isLoading;
  final VoidCallback onConfirm;

  const CartBottomBar({
    super.key,
    required this.totalPrice,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
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
                text: isLoading
                    ? "wait".tr(context)
                    : "confirm_order".tr(context),
                iconData: FontAwesomeIcons.cartShopping,
                mainColor: AppColors.shadowGreen,
                backgroundColor: AppColors.green,
                onTap: onConfirm,
              ),
            ),

            const SizedBox(width: 24),
            Text(
              totalPrice,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
