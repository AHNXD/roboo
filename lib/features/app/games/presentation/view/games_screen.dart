import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';

class GamesScreen extends StatelessWidget {
  static const String routeName = '/games';

  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "games_title".tr(context)),
      body: SafeArea(
        child: StatusDisplayWidget(message: "feature_coming_soon".tr(context)),
      ),
    );
  }
}
