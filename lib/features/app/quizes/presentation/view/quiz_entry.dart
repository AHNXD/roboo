import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';

import 'quiz_screen.dart';

/// The one way into a quiz.
///
/// A quiz pays its points out once, and the backend refuses a second attempt on
/// a course or lesson quiz outright — so a solved quiz is not opened at all.
/// Letting the student answer everything again only to be rejected at submit
/// would waste their time and lose their answers.
///
/// [onClosed] fires when the student comes back. `solved` is computed
/// server-side and travels with the quiz, so the screen that opened it has to
/// re-fetch before it can know the quiz is now done — otherwise the row still
/// says "open" and lets them straight back in.
Future<void> openQuizIfUnsolved(
  BuildContext context, {
  required int? quizId,
  required bool isSolved,
  VoidCallback? onClosed,
}) async {
  if (quizId == null) return;

  if (isSolved) {
    messages(
      context,
      "quiz_already_solved".tr(context),
      AppColors.primaryColors,
    );
    return;
  }

  await Navigator.pushNamed(
    context,
    QuizScreen.routeName,
    arguments: QuizArgs(quizId: quizId),
  );

  onClosed?.call();
}
