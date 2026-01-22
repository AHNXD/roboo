import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final double? scaleFactor;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.scaleFactor,
  });

  double _calculateResponsiveFontSize(BuildContext context) {
    final double baseFontSize = style?.fontSize ?? 14.0;

    final double screenWidth = MediaQuery.of(context).size.width;

    const double minScale = 0.8;
    const double maxScale = 1.2;

    double scale = screenWidth / 400.0;

    if (scale < minScale) {
      scale = minScale;
    } else if (scale > maxScale) {
      scale = maxScale;
    }

    if (scaleFactor != null) {
      scale *= scaleFactor!;
    }

    return baseFontSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    final double responsiveFontSize = _calculateResponsiveFontSize(context);

    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: responsiveFontSize,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: softWrap,
    );
  }
}
