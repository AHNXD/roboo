import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';
import 'package:roboo/features/app/cart/presentation/view/cart_screen.dart';
import 'package:roboo/features/app/profile/data/models/cached_profile_user.dart';
import 'package:roboo/features/app/profile/presentation/view/profile_menu_screen.dart';

class TopBarWidget extends StatefulWidget {
  const TopBarWidget({super.key});

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  CachedProfileUser _user = CachedProfileUser.fromCache();

  void _refreshUser() {
    setState(() => _user = CachedProfileUser.fromCache());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Image.asset(AssetsData.menu, height: 24),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, CartScreen.routeName);
            },
            icon: Image.asset(AssetsData.cart, height: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: Image.asset(AssetsData.bell, height: 24),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const ProfileMenuScreen()),
              );
              if (mounted) {
                _refreshUser();
              }
            },
            child: HexagonProfileAvatar(imagePath: _user.image, size: 60),
          ),
        ],
      ),
    );
  }
}
