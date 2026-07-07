import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';

class FavIcon extends StatelessWidget {
  final bool isFav;
  final bool isLoading;
  final VoidCallback? onTap;

  const FavIcon({
    super.key,
    required this.isFav,
    this.isLoading = false,
    this.onTap,
  });

  static const List<double> grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 32,
            height: 32,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : isFav
        ? Image.asset(AssetsData.fav, width: 32, height: 32)
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(grayscaleMatrix),
            child: Image.asset(AssetsData.fav, width: 32, height: 32),
          );

    if (onTap == null) return child;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(padding: const EdgeInsets.all(2), child: child),
    );
  }
}
