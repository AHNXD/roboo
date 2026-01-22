import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          HexagonProfileAvatar(imagePath: AssetsData.profile, size: 60),
          const Spacer(),
          IconButton(onPressed: () {}, icon: Image.asset(AssetsData.bell)),
          IconButton(onPressed: () {}, icon: Image.asset(AssetsData.cart)),
          IconButton(onPressed: () {}, icon: Image.asset(AssetsData.menu)),
        ],
      ),
    );
  }
}

class HexagonProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;

  const HexagonProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return HexagonWidget.flat(
      width: size,
      color: AppColors.primaryColors,
      elevation: 4,
      cornerRadius: 8,
      child: imagePath.isNotEmpty
          ? HexagonWidget.flat(
              width: size,
              color: AppColors.primaryColors,
              padding: 4.0,
              cornerRadius: 8,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: size,
                height: size,
              ),
            )
          : Container(),
    );
  }
}
