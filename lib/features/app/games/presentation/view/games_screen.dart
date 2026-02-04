import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';

class GamesScreen extends StatelessWidget {
  static const String routeName = '/games';

  GamesScreen({super.key});

  // Mock Data
  final List<GameItemModel> _games = [
    GameItemModel(title: "الدودة", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "السلم و الأفعى", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "لودو", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "لعبة الذاكرة", duration: "20 دقيقة / 1 ساعة"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الألعاب"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                itemCount: _games.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return _buildGameRow(_games[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRow(GameItemModel game) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSkewedIcon(),
          const SizedBox(width: 20),
          Text(
            game.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timelapse_sharp, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                game.duration,

                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkewedIcon() {
    const double skewAmount = -0.25;

    return Transform(
      // Apply the Skew to the container
      transform: Matrix4.skewX(skewAmount),
      alignment: Alignment.center,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF7FB5B7), // Teal color from image
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        // Counter-skew the child so the Icon stays straight
        child: Transform(
          transform: Matrix4.skewX(-skewAmount),
          alignment: Alignment.center,
          child: const Center(
            child: Icon(
              Icons.gamepad, // Or use AssetsData.gameIcon if available
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class GameItemModel {
  final String title;
  final String duration;

  GameItemModel({required this.title, required this.duration});
}
