import 'package:flutter/material.dart';
import 'package:roboo/features/app/notifications/presentation/view-model/notifications_badge_cubit/notifications_badge_cubit.dart';
import 'package:roboo/features/app/cart/presentation/view-model/cart_cubit/cart_cubit.dart';
import 'package:roboo/core/widgets/icon_badge.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/hexagon_avatar_widget.dart';
import 'package:roboo/features/app/cart/presentation/view/cart_screen.dart';
import 'package:roboo/features/app/notifications/presentation/view/notifications_screen.dart';
import 'package:roboo/features/app/profile/data/models/cached_profile_user.dart';
import 'package:roboo/features/app/profile/presentation/view/profile_menu_screen.dart';

class TopBarWidget extends StatefulWidget {
  const TopBarWidget({super.key});

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  CachedProfileUser _user = CachedProfileUser.fromCache();

  @override
  void initState() {
    super.initState();
    // Both badges must be right before their screens have ever been opened, so
    // the counts are fetched here rather than by the cart and notification
    // screens. Guarded inside each cubit against repeat calls, since this bar
    // appears on four tabs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getit.get<NotificationsBadgeCubit>().refresh();
      getit.get<CartCubit>().loadCartIfNeeded();
    });
  }

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
          BlocBuilder<CartCubit, CartState>(
            bloc: getit.get<CartCubit>(),
            builder: (context, state) => IconBadge(
              count: state.cart.summary.itemCount,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, CartScreen.routeName);
                },
                icon: Image.asset(AssetsData.cart, height: 24),
              ),
            ),
          ),
          BlocBuilder<NotificationsBadgeCubit, int>(
            bloc: getit.get<NotificationsBadgeCubit>(),
            builder: (context, unreadCount) => IconBadge(
              count: unreadCount,
              child: IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    NotificationsScreen.routeName,
                  );
                  // Anything read while in there changes the count.
                  await getit.get<NotificationsBadgeCubit>().refresh();
                },
                icon: Image.asset(AssetsData.bell, height: 24),
              ),
            ),
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
