import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? actions;
  final double toolbarHeight;

  const CustomAppbar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackButtonPressed,
    this.actions,
    this.toolbarHeight = kToolbarHeight + 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: toolbarHeight.toDouble(),
          decoration: BoxDecoration(
            color: AppColors.primaryColors,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر العودة (اختياري)
              SizedBox(
                width: 48,
                child: showBackButton
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed:
                            onBackButtonPressed ??
                            () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                        splashRadius: 24,
                      )
                    : null,
              ),

              // العنوان المركزي
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
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
