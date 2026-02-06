import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/games/presentation/view/widgets/game_list_item_widget.dart';

// Model Class
class GameItemModel {
  final String title;
  final String duration;

  GameItemModel({required this.title, required this.duration});
}

class GamesScreen extends StatelessWidget {
  static const String routeName = '/games';

  GamesScreen({super.key});

  final List<GameItemModel> _games = [
    GameItemModel(title: "الدودة", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "السلم و الأفعى", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "لودو", duration: "20 دقيقة / 1 ساعة"),
    GameItemModel(title: "لعبة الذاكرة", duration: "20 دقيقة / 1 ساعة"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "games_title".tr(context)),
      body: SafeArea(
        child: _games.isEmpty
            ? StatusDisplayWidget(message: "no_games_available".tr(context))
            : Column(
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
                        final game = _games[index];
                        return GameListItem(
                          title: game.title,
                          duration: game.duration,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
