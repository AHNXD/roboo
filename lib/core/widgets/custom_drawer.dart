import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';

import 'package:roboo/features/app/games/presentation/view/games_screen.dart';
import 'package:roboo/features/app/leaderboard/presentation/view/leaderboard_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/quizes_screen.dart';
import 'package:roboo/features/auth/presentation/view-model/logout_cubit/logout_cubit.dart';
import 'package:roboo/features/shared/on-boarding/presentation/view/on_boarding_screen.dart';
import 'package:roboo/features/shared/settings/view/settings_screen.dart';

import 'custom_3d_btn.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (_) => LogoutCubit(getit.get()),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              OnboardingScreen.routeName,
              (route) => false,
            );
          } else if (state is LogoutError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is LogoutLoading;

          return Drawer(
            backgroundColor: Colors.white,
            width: MediaQuery.of(context).size.width * 0.70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: isRtl ? const Radius.circular(20) : Radius.zero,
                bottomLeft: isRtl ? const Radius.circular(20) : Radius.zero,
                topRight: isRtl ? Radius.zero : const Radius.circular(20),
                bottomRight: isRtl ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // 1. Header (Logo)
                Container(
                  height: 240,
                  width: double.infinity,
                  color: AppColors.primaryColors,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 54,
                  ),
                  child: Image.asset(AssetsData.logo, color: Colors.white),
                ),

                const SizedBox(height: 40),

                // 2. Menu Items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        DrawerItem(
                          label: "leaderboard_title".tr(context), // Reused key
                          imagePath: AssetsData.leaderBoard,
                          onTap: () => Navigator.pushNamed(
                            context,
                            LeaderboardScreen.routeName,
                          ),
                        ),
                        DrawerItem(
                          label: "games_title".tr(context), // Reused key
                          imagePath: AssetsData.games,
                          onTap: () => Navigator.pushNamed(
                            context,
                            GamesScreen.routeName,
                          ),
                        ),
                        DrawerItem(
                          label: "quizzes_title".tr(context), // Reused key
                          imagePath: AssetsData.quizes,
                          onTap: () => Navigator.pushNamed(
                            context,
                            QuizesScreen.routeName,
                          ),
                        ),
                        DrawerItem(
                          label: "settings_title".tr(context), // New key
                          imagePath: AssetsData.settings,
                          onTap: () => Navigator.pushNamed(
                            context,
                            SettingsScreen.routeName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Logout Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Custom3DButton(
                    text: isLoading
                        ? "logout_loading".tr(context)
                        : "logout".tr(context),
                    mainColor: AppColors.primaryColors,
                    iconData: Icons.logout,
                    onTap: isLoading
                        ? () {}
                        : () => context.read<LogoutCubit>().logout(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(imagePath, width: 28, height: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
