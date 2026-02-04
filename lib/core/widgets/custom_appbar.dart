import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';

import '../utils/colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? actions;
  final double toolbarHeight;
  final bool isWhite;

  const CustomAppbar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackButtonPressed,
    this.actions,
    this.toolbarHeight = kToolbarHeight + 16.0,
    this.isWhite = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: toolbarHeight.toDouble(),

          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 48,
                child: showBackButton
                    ? CustomBackButton(
                        isWhite: isWhite,
                        onTap:
                            onBackButtonPressed ??
                            () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                      )
                    : null,
              ),

              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: isWhite ? AppColors.primaryColors : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(
                child: actions != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      )
                    : const SizedBox(width: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight.toDouble());
}
