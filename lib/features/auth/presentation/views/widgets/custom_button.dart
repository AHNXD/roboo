import 'package:flutter/material.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/constats.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    this.verticalHieght,
    this.horizontalWidth,
    this.color,
    this.textStyle,
    this.height,
    required this.child,
  });

  final void Function() onPressed;
  final double? verticalHieght;
  final double? horizontalWidth;
  final Color? color;
  final TextStyle? textStyle;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalHieght ?? kVerticalPadding,
        horizontal: horizontalWidth ?? kHorizontalPadding,
      ),
      child: MaterialButton(
        color: color ?? AppColors.primaryColors,
        height: height ?? 45,
        minWidth: double.infinity,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
