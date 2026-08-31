import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/quizes/data/models/question_model.dart';
import 'package:roboo/features/app/quizes/data/models/quiz_result_model.dart';
import 'package:roboo/features/app/quizes/presentation/view-model/quiz_result_cubit/quiz_result_cubit.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_option_item_widget.dart';

class QuizResultArgs {
  final int quizId;

  /// question id -> chosen answer id
  final Map<int, int> answers;

  /// The questions as they were answered, so the review can show text rather
  /// than the ids `question_results` returns.
  final List<QuestionModel> questions;

  const QuizResultArgs({
    required this.quizId,
    required this.answers,
    this.questions = const [],
  });

  static QuizResultArgs? from(Object? args) =>
      args is QuizResultArgs ? args : null;
}

class QuizResultScreen extends StatelessWidget {
  static const String routeName = '/quiz-result';

  final QuizResultArgs? args;

  const QuizResultScreen({super.key, required this.args});

  factory QuizResultScreen.fromRouteArgs(Object? routeArgs) {
    return QuizResultScreen(args: QuizResultArgs.from(routeArgs));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizResultCubit(getit.get(), getit.get())
        ..submitQuiz(quizId: args?.quizId, answers: args?.answers ?? const {}),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: DotBackground()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocBuilder<QuizResultCubit, QuizResultState>(
                  builder: (context, state) {
                    return switch (state) {
                      QuizResultInitial() ||
                      QuizResultLoading() => StatusDisplayWidget(
                        message: "quiz_submitting".tr(context),
                        withAnimation: true,
                      ),
                      QuizResultError(:final errorMsg) => _ErrorView(
                        message: errorMsg.tr(context),
                      ),
                      QuizResultLoaded(:final result) => _ResultView(
                        result: result,
                        quizId: args?.quizId,
                        questions: args?.questions ?? const [],
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StatusDisplayWidget(
            message: message,
            imagePath: AssetsData.sadRoboo,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: PrimaryButton(
            text: "back".tr(context),
            backgroundColor: AppColors.primaryColors,
            mainColor: AppColors.primaryTwoColors,
            enterButton: true,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  final QuizResultModel result;
  final int? quizId;
  final List<QuestionModel> questions;

  const _ResultView({
    required this.result,
    required this.quizId,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    // Judged on the answers, never on `points_earned`: a quiz solved before
    // scores full marks but pays 0 points the second time, and calling that a
    // failure told a student with 3/3 to try again.
    // The server refused to grade this attempt — there is no score, so the
    // refusal is all there is to show.
    if (result.isRejected) return _buildRejected(context);

    final isSuccess = result.isPassed;
    // Full marks but nothing awarded means the points were already banked.
    final alreadyRewarded = result.wasAlreadyRewarded;

    return Column(
      children: [
        // Scrolls, because the per-question review can be long; the action
        // button stays pinned to the bottom.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                StatusDisplayWidget(
                  message: isSuccess
                      ? "quiz_success".tr(context)
                      : "quiz_fail".tr(context),
                  imagePath: isSuccess
                      ? AssetsData.happyRoboo
                      : AssetsData.sadRoboo,
                ),

                const SizedBox(height: 20),
                _buildScoreCard(context, isSuccess),

                if (result.questionResults.isNotEmpty && questions.isNotEmpty)
                  _buildReview(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Retry is only offered while the server would still accept one. After
        // any attempt it refuses to pay points again, and a course or lesson
        // quiz refuses the attempt outright.
        PrimaryButton(
          text: !result.canRetry
              ? (alreadyRewarded || result.pointsEarned <= 0
                    ? "back".tr(context)
                    : "${"earn_points".tr(context)} ${result.pointsEarned} ")
              : "retry".tr(context),
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          enterButton: true,
          onTap: () {
            if (!result.canRetry || quizId == null) {
              Navigator.pop(context);
              return;
            }

            // Retry replaces the result so the back stack does not fill up
            // with abandoned attempts.
            Navigator.pushReplacementNamed(
              context,
              QuizScreen.routeName,
              arguments: QuizArgs(quizId: quizId!),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// A refused attempt. The backend's message is an English sentence rather
  /// than a translation key, so the app shows its own wording and keeps the
  /// server's text out of the UI.
  Widget _buildRejected(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        StatusDisplayWidget(
          message: "quiz_already_solved".tr(context),
          imagePath: AssetsData.happyRoboo,
        ),
        const Spacer(),
        PrimaryButton(
          text: "back".tr(context),
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          enterButton: true,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Correctness here comes from the server's `question_results`, not from the
  /// `is_correct` the quiz detail ships alongside the questions.
  Widget _buildReview(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "quiz_review".tr(context),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...result.questionResults.map((questionResult) {
            final question = _questionFor(questionResult.questionId);
            if (question == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        questionResult.isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                        color: questionResult.isCorrect
                            ? Colors.green
                            : AppColors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.questionTextFor(languageCode),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...question.answers.map((answer) {
                    final isCorrectAnswer =
                        answer.id != null &&
                        answer.id == questionResult.correctAnswerId;
                    final isChosen =
                        answer.id != null &&
                        answer.id == questionResult.selectedAnswerId;

                    // Only the chosen and the correct answer are marked; the
                    // rest stay neutral.
                    Color? color;
                    IconData? icon;
                    if (isCorrectAnswer) {
                      color = Colors.green;
                      icon = Icons.check_circle;
                    } else if (isChosen) {
                      color = AppColors.red;
                      icon = Icons.cancel;
                    }

                    return QuizOptionItem(
                      text: answer.answerTextFor(languageCode),
                      isSelected: isChosen,
                      borderColor: color,
                      iconColor: color,
                      icon: icon,
                      onTap: null,
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  QuestionModel? _questionFor(int? questionId) {
    if (questionId == null) return null;

    for (final question in questions) {
      if (question.id == questionId) return question;
    }
    return null;
  }

  Widget _buildScoreCard(BuildContext context, bool isSuccess) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "quiz_your_score".tr(context),
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            "${result.score}/${result.total}",
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSuccess ? AppColors.shadowGreen : AppColors.red,
            ),
          ),
          const SizedBox(height: 8),
          if (result.wasAlreadyRewarded)
            Text(
              "quiz_already_solved".tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!result.wasAlreadyRewarded) ...[
                const Icon(Icons.star, size: 16, color: Color(0xFF7FB5B7)),
                const SizedBox(width: 4),
                Text(
                  "${result.pointsEarned} ${"points".tr(context)}",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7FB5B7),
                  ),
                ),
              ],
              if (result.isPerfect) ...[
                const SizedBox(width: 10),
                Text(
                  "quiz_perfect".tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.shadowGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
