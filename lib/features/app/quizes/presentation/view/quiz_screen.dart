import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/quizes/presentation/view-model/quiz_cubit/quiz_cubit.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_result_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_option_item_widget.dart';

import '../../../../auth/presentation/views/widgets/step_progress_bar.dart';

class QuizArgs {
  final int quizId;

  const QuizArgs({required this.quizId});

  static int? quizIdFrom(Object? args) {
    if (args is QuizArgs) return args.quizId;
    if (args is int) return args;
    if (args is Map && args['quizId'] is int) {
      return args['quizId'] as int;
    }
    return null;
  }
}

class QuizScreen extends StatelessWidget {
  static const String routeName = '/quiz';

  final int? quizId;

  const QuizScreen({super.key, required this.quizId});

  factory QuizScreen.fromRouteArgs(Object? args) {
    return QuizScreen(quizId: QuizArgs.quizIdFrom(args));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(getit.get())..getQuiz(quizId),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: DotBackground()),

              BlocConsumer<QuizCubit, QuizState>(
                listener: (context, state) {
                  if (state is QuizCompleted) {
                    if (state.isTimeUp) {
                      messages(
                        context,
                        "quiz_time_up".tr(context),
                        AppColors.red,
                      );
                    }
                    _openResult(context, state);
                  } else if (state is QuizTimeExpired) {
                    // Nothing was answered, so there is no result to show.
                    messages(
                      context,
                      "quiz_time_up".tr(context),
                      AppColors.red,
                    );
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      const SizedBox(height: 10),

                      if (state is QuizQuestionLoaded)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              CustomBackButton(
                                onTap: () => Navigator.pop(context),
                                isWhite: true,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StepProgressBar(
                                  currentStep: state.questionIndex + 1,
                                  totalSteps: state.totalQuestions,
                                ),
                              ),
                              if (state.isTimed) ...[
                                const SizedBox(width: 12),
                                _CountdownPill(state: state),
                              ],
                            ],
                          ),
                        ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildBody(context, state),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Replaces the quiz so the finished attempt is not left on the back stack.
  void _openResult(BuildContext context, QuizCompleted state) {
    final id = quizId;
    if (id == null) return;

    Navigator.pushReplacementNamed(
      context,
      QuizResultScreen.routeName,
      arguments: QuizResultArgs(
        quizId: id,
        answers: state.answers,
        questions: state.questions,
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    return switch (state) {
      // QuizCompleted only lives long enough for the listener to navigate.
      QuizInitial() ||
      QuizLoading() ||
      QuizCompleted() ||
      QuizTimeExpired() => StatusDisplayWidget(
        message: "quiz_loading".tr(context),
        withAnimation: true,
      ),
      QuizError(:final errorMsg) => StatusDisplayWidget(
        message: errorMsg.tr(context),
      ),
      QuizEmpty() => StatusDisplayWidget(
        message: "no_questions_available".tr(context),
      ),
      QuizQuestionLoaded() => _QuestionView(state: state),
    };
  }
}

class _QuestionView extends StatelessWidget {
  final QuizQuestionLoaded state;

  const _QuestionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final quizCubit = context.read<QuizCubit>();

    return Column(
      children: [
        const Spacer(),
        // Question Bubble
        Hero(
          tag: 'message_bubble',
          child: RobotMessageBubble(
            message: state.question.questionTextFor(languageCode),
          ),
        ),
        const Spacer(),

        // Options List
        ...state.question.answers.map((answer) {
          return QuizOptionItem(
            text: answer.answerTextFor(languageCode),
            isSelected: state.selectedAnswerId == answer.id,
            onTap: () => quizCubit.selectAnswer(answer.id),
          );
        }),

        const Spacer(),

        // Answers are no longer graded here — the backend stopped sending the
        // key — so picking one and moving on is the whole interaction.
        PrimaryButton(
          text: state.isLastQuestion
              ? "finish_quiz".tr(context)
              : "next".tr(context),
          backgroundColor: state.selectedAnswerId == null
              ? Colors.grey
              : AppColors.primaryColors,
          mainColor: state.selectedAnswerId == null
              ? Colors.grey.shade400
              : AppColors.primaryTwoColors,
          enterButton: true,
          onTap: quizCubit.goToNextQuestion,
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

/// The remaining time. Turns red for the last minute so the student notices
/// before the quiz submits itself.
class _CountdownPill extends StatelessWidget {
  final QuizQuestionLoaded state;

  const _CountdownPill({required this.state});

  @override
  Widget build(BuildContext context) {
    final isUrgent = state.isRunningOut;
    final color = isUrgent ? AppColors.red : AppColors.primaryColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.timer : Icons.timer_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            state.formattedTimeLeft,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              // Keeps the pill from twitching as the digits change.
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
