import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_option_item_widget.dart';

import '../../../../auth/presentation/views/widgets/step_progress_bar.dart';

enum QuizState { loading, question, success, failure }

class QuizScreen extends StatefulWidget {
  static const String routeName = '/quiz';
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizState _currentState = QuizState.question;
  final int _totalQuestions = 40;
  final int _currentQuestionIndex = 12;

  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;
  final int _correctAnswerIndex = 3;
  final List<String> _options = ["cout", "log", "print", "System.out.print"];

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;

    setState(() => _isAnswerChecked = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (_selectedAnswerIndex == _correctAnswerIndex) {
        setState(() => _currentState = QuizState.success);
      } else {
        setState(() => _currentState = QuizState.failure);
      }
    });
  }

  void _retry() {
    setState(() {
      _currentState = QuizState.question;
      _isAnswerChecked = false;
      _selectedAnswerIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),

            Column(
              children: [
                const SizedBox(height: 10),

                if (_currentState == QuizState.question)
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
                            currentStep: _currentQuestionIndex + 1,
                            totalSteps: _totalQuestions,
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildBody(),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case QuizState.loading:
        return StatusDisplayWidget(message: "quiz_loading".tr(context));
      case QuizState.success:
        return _buildResultView(isSuccess: true);
      case QuizState.failure:
        return _buildResultView(isSuccess: false);
      case QuizState.question:
        return _buildQuestionView();
    }
  }

  Widget _buildQuestionView() {
    return Column(
      children: [
        const Spacer(),
        // Question Bubble
        const Hero(
          tag: 'message_bubble',
          child: RobotMessageBubble(
            message: "ما هي ال keyword المسؤولة عن عملية الطباعة في Java؟",
          ),
        ),
        const Spacer(),

        // Options List
        ...List.generate(_options.length, (index) {
          Color? borderColor;
          Color? iconColor;
          IconData? icon;

          if (_isAnswerChecked) {
            if (index == _correctAnswerIndex) {
              borderColor = Colors.green;
              iconColor = Colors.green;
              icon = Icons.check_circle;
            } else if (index == _selectedAnswerIndex) {
              borderColor = Colors.red;
              iconColor = Colors.red;
              icon = Icons.cancel;
            }
          }

          return QuizOptionItem(
            text: _options[index],
            isSelected: _selectedAnswerIndex == index,
            borderColor: borderColor,
            iconColor: iconColor,
            icon: icon,
            onTap: !_isAnswerChecked
                ? () => setState(() => _selectedAnswerIndex = index)
                : null,
          );
        }),

        const Spacer(),

        PrimaryButton(
          text: _isAnswerChecked
              ? "next".tr(context)
              : "check_answer".tr(context),
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          onTap: _submitAnswer,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultView({required bool isSuccess}) {
    return Column(
      children: [
        const Spacer(),

        StatusDisplayWidget(
          message: isSuccess
              ? "quiz_success".tr(context)
              : "quiz_fail".tr(context),
          imagePath: isSuccess ? AssetsData.happyRoboo : AssetsData.sadRoboo,
        ),

        const Spacer(),

        PrimaryButton(
          text: isSuccess ? "earn_points".tr(context) : "retry".tr(context),
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          imagePath: AssetsData.forwardButton, // Arrow icon
          onTap: isSuccess ? () => Navigator.pop(context) : _retry,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
