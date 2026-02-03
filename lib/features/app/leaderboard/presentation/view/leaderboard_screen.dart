import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';

class Competitor {
  final int rank;
  final String name;
  final int points;
  final String image;
  final bool isCurrentUser;

  Competitor({
    required this.rank,
    required this.name,
    required this.points,
    required this.image,
    this.isCurrentUser = false,
  });
}

class LeaderboardScreen extends StatelessWidget {
  static const String routeName = '/leaderboard';

  LeaderboardScreen({super.key});

  final List<Competitor> _competitors = [
    Competitor(
      rank: 1,
      name: "مجد",
      points: 1500,
      image: AssetsData.profile,
    ), // Replace with real asset
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
      appBar: CustomAppbar(title: "لائحة المنافسين"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    _buildPodium(context),

                    const SizedBox(height: 30),

                    ..._competitors.skip(3).map((c) => _buildListItem(c)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildPodium(BuildContext context) {
    if (_competitors.length < 3) return const SizedBox();

    final first = _competitors[0];
    final second = _competitors[1];
    final third = _competitors[2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(second, size: 90, color: AppColors.primaryColors),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Image.asset(AssetsData.crown, color: const Color(0xFFFFCA28)),

                _buildPodiumItem(
                  first,
                  size: 140,
                  color: const Color(0xFFFFCA28),
                  isFirst: true,
                ),
              ],
            ),
          ),
          _buildPodiumItem(third, size: 90, color: AppColors.primaryColors),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    Competitor data, {
    required double size,
    required Color color,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            HexagonProfileAvatar(
              imagePath: data.image,
              size: size,
              borderColor: color,
            ),

            Transform.translate(
              offset: const Offset(0, 12),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "${data.rank}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "${data.points} نقطة",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(Competitor data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Highlight logic for current user
        color: data.isCurrentUser
            ? AppColors.primaryColors.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryColors,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${data.rank}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          HexagonProfileAvatar(
            imagePath: data.image,
            size: 50,
            borderColor: AppColors.primaryColors,
          ),
          SizedBox(width: 12),
          Text(
            data.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const Spacer(),
          Text(
            "${data.points} نقطة",
            style: TextStyle(
              color: AppColors.primaryColors.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Hexagon Widget tailored for this screen
class HexagonProfileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color borderColor;

  const HexagonProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.borderColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return HexagonWidget.flat(
      width: size,
      color: borderColor,
      elevation: 6,
      cornerRadius: 10,
      child: HexagonWidget.flat(
        width: size - 6,
        color: Colors.white,
        padding: 2.0,
        cornerRadius: 10,
        child: ClipRRect(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.person, color: borderColor),
          ),
        ),
      ),
    );
  }
}
