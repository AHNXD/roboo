import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/cart/presentation/view/cart_screen.dart';
import 'package:roboo/features/app/profile/presentation/view/profile_menu_screen.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Image.asset(AssetsData.menu),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, CartScreen.routeName);
            },
            icon: Image.asset(AssetsData.cart),
          ),
          IconButton(onPressed: () {}, icon: Image.asset(AssetsData.bell)),

          const Spacer(),

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ProfileMenuScreen()),
            ),
            child: HexagonProfileAvatar(
              imagePath: AssetsData.profile,
              size: 60,
            ),
          ),
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
