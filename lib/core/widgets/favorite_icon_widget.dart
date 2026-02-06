import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';

class ProductFavIcon extends StatelessWidget {
  final bool isFav;

  const ProductFavIcon({super.key, required this.isFav});

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
    return isFav
        ? Image.asset(AssetsData.fav, width: 40, height: 40)
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(grayscaleMatrix),
            child: Image.asset(AssetsData.fav, width: 40, height: 40),
          );
  }
}
