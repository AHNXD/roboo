import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/colors.dart';

class HexagonProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const HexagonProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.borderColor = AppColors.primaryColors,
  });

  @override
  Widget build(BuildContext context) {
    return HexagonWidget.pointy(
      width: size,
      color: borderColor,
      elevation: 6,
      cornerRadius: 10,
      child: HexagonWidget.pointy(
        width: size - 6,
        color: Colors.white,
        padding: 2.0,
        cornerRadius: 10,
        child: ClipRRect(
          child: _ProfileAvatarImage(
            imagePath: imagePath,
            borderColor: borderColor,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatarImage extends StatelessWidget {
  final String imagePath;
  final Color borderColor;

  const _ProfileAvatarImage({
    required this.imagePath,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final errorWidget = Icon(Icons.person, color: borderColor);
    if (imagePath.isEmpty) {
      return errorWidget;
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }

    if (imagePath.startsWith('/')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => errorWidget,
    );
  }
}
