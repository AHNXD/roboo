import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';

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

    setState(() {
      _isAnswerChecked = true;
    });

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
        return _buildLoadingView();
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
        Spacer(),

        const Hero(
          tag: 'message_bubble',
          child: RobotMessageBubble(
            message: "ما هي ال keyword المسؤولة عن عملية الطباعة في Java؟",
          ),
        ),
        Spacer(),

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

          return _buildOptionItem(index, borderColor, iconColor, icon);
        }),

        Spacer(),

        PrimaryButton(
          text: _isAnswerChecked ? "التالي" : "تحقق من الرمز",
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          onTap: _submitAnswer,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOptionItem(
    int index,
    Color? borderColor,
    Color? iconColor,
    IconData? icon,
  ) {
    bool isSelected = _selectedAnswerIndex == index;

    Color finalBorder =
        borderColor ??
        (isSelected
            ? AppColors.primaryColors
            : Colors.grey.withValues(alpha: 0.3));

    return GestureDetector(
      onTap: !_isAnswerChecked
          ? () => setState(() => _selectedAnswerIndex = index)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: finalBorder, width: 2),

          boxShadow: (isSelected || borderColor != null)
              ? [
                  BoxShadow(
                    color: finalBorder.withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _options[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor ?? Colors.black87,
              ),
            ),
            Icon(
              icon ??
                  (isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
              color:
                  iconColor ??
                  (isSelected ? AppColors.primaryColors : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsData.flyingRoboo),
          const SizedBox(height: 30),
          const Text(
            "...جار تحميل الاختبار",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView({required bool isSuccess}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset(isSuccess ? AssetsData.happyRoboo : AssetsData.sadRoboo),

        const SizedBox(height: 40),

        Text(
          isSuccess
              ? "!لقد نجحت في الاختبار"
              : "لا بأس!\n...هيّا نعيد المحاولة",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),

        const Spacer(),

        PrimaryButton(
          text: isSuccess ? "اكسب 50 نقطة" : "إعادة المحاولة",
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          imagePath: AssetsData.forwardButton,
          onTap: isSuccess ? () => Navigator.pop(context) : _retry,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
