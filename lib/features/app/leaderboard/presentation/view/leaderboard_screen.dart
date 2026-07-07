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
                LeaderboardInitial() || LeaderboardLoading() => const Center(
                  child: CircularProgressIndicator(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place (Left)
              PodiumItem(
                competitor: second,
                size: 90,
                color: AppColors.primaryColors,
              ),

              // 1st Place (Center)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PodiumItem(
                  competitor: first,
                  size: 140,
                  color: const Color(0xFFFFCA28),
                  isFirst: true,
                ),
              ),

              // 3rd Place (Right)
              PodiumItem(
                competitor: third,
                size: 90,
                color: AppColors.primaryColors,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
