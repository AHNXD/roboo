import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/leaderboard/data/models/competitor_model.dart';
import 'package:roboo/features/app/leaderboard/presentation/view/widgets/leaderboard_list_item_widget.dart';
import 'package:roboo/features/app/leaderboard/presentation/view/widgets/podium_item_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  static const String routeName = '/leaderboard';

  LeaderboardScreen({super.key});

  // Mock Data
  final List<Competitor> _competitors = [
    Competitor(rank: 1, name: "مجد", points: 1500, image: AssetsData.profile),
    Competitor(rank: 2, name: "سارة", points: 1400, image: AssetsData.profile),
    Competitor(rank: 3, name: "أحمد", points: 1300, image: AssetsData.profile),
    Competitor(rank: 4, name: "ماري", points: 1000, image: AssetsData.profile),
    Competitor(rank: 5, name: "حسام", points: 970, image: AssetsData.profile),
    Competitor(rank: 6, name: "آية", points: 920, image: AssetsData.profile),
    Competitor(
      rank: 7,
      name: "كريم",
      points: 890,
      image: AssetsData.profile,
      isCurrentUser: true,
    ),
    Competitor(rank: 8, name: "مارك", points: 845, image: AssetsData.profile),
    Competitor(rank: 9, name: "أمل", points: 760, image: AssetsData.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "leaderboard_title".tr(context)),
      body: SafeArea(
        child: _competitors.isEmpty
            ? StatusDisplayWidget(message: "no_competitors_yet".tr(context))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // 1. Top 3 Podium Section (Now with Animation)
                    _buildPodiumSection(context),

                    const SizedBox(height: 30),

                    // 2. The Rest of the List (Rank 4+)
                    ..._competitors
                        .skip(3)
                        .map((c) => LeaderboardListItem(competitor: c)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPodiumSection(BuildContext context) {
    if (_competitors.length < 3) return const SizedBox();

    final first = _competitors[0];
    final second = _competitors[1];
    final third = _competitors[2];

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
