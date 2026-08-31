import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/leaderboard/data/models/competitor_model.dart';
import 'package:roboo/features/app/leaderboard/presentation/view-model/leaderboard_cubit/leaderboard_cubit.dart';
import 'package:roboo/features/app/leaderboard/presentation/view/widgets/leaderboard_list_item_widget.dart';
import 'package:roboo/features/app/leaderboard/presentation/view/widgets/podium_item_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  static const String routeName = '/leaderboard';

  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaderboardCubit(getit.get())..getLeaderboard(),
      child: Scaffold(
        appBar: CustomAppbar(title: "leaderboard_title".tr(context)),
        body: SafeArea(
          child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
            builder: (context, state) {
              return switch (state) {
                LeaderboardInitial() ||
                LeaderboardLoading() => StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
                LeaderboardEmpty() => StatusDisplayWidget(
                  message: "no_competitors_yet".tr(context),
                ),
                LeaderboardError(:final errorMsg) => StatusDisplayWidget(
                  message: errorMsg.tr(context),
                ),
                LeaderboardLoaded(:final competitors) => _LeaderboardContent(
                  competitors: competitors,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  final List<Competitor> competitors;

  const _LeaderboardContent({required this.competitors});

  @override
  Widget build(BuildContext context) {
    final listCompetitors = competitors.length < 3
        ? competitors
        : competitors.skip(3);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // 1. Top 3 Podium Section (Now with Animation)
          _buildPodiumSection(context),

          const SizedBox(height: 30),

          // 2. The Rest of the List (Rank 4+)
          ...listCompetitors.map((c) => LeaderboardListItem(competitor: c)),
        ],
      ),
    );
  }

  Widget _buildPodiumSection(BuildContext context) {
    if (competitors.length < 3) return const SizedBox();

    final first = competitors[0];
    final second = competitors[1];
    final third = competitors[2];

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -50,
          left: 0,
          right: 0,
          child: Lottie.asset(
            AssetsData.celebrationAnimation,
            height: 300,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          // Each place takes a fixed share of the row, so a long name is
          // bounded by its own slot instead of pushing into its neighbours.
          // The avatars scale with that share, so the winner's hexagon still
          // fits on a narrow phone.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth;

              // The avatars are derived from the slot each flex share gives
              // them, never from the screen width directly — sized off the
              // screen they outgrow their own slot on anything narrower than
              // about 412pt and the hexagon itself overflows.
              final sideSlot = available * 3 / 10;
              final firstSlot = available * 4 / 10 - 8; // the centre padding
              final firstSize = (firstSlot * 0.95).clamp(70.0, 140.0);
              final sideSize = (sideSlot * 0.85).clamp(56.0, 90.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place (Left)
                  Expanded(
                    flex: 3,
                    child: PodiumItem(
                      competitor: second,
                      size: sideSize,
                      color: AppColors.primaryColors,
                    ),
                  ),

                  // 1st Place (Center)
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: PodiumItem(
                        competitor: first,
                        size: firstSize,
                        color: const Color(0xFFFFCA28),
                        isFirst: true,
                      ),
                    ),
                  ),

                  // 3rd Place (Right)
                  Expanded(
                    flex: 3,
                    child: PodiumItem(
                      competitor: third,
                      size: sideSize,
                      color: AppColors.primaryColors,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
