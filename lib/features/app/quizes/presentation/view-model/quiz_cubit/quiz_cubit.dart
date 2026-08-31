import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/error_handler.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repos/quizzes_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> with SafeEmit<QuizState> {
  final QuizzesRepo _quizzesRepo;

  QuizCubit(this._quizzesRepo) : super(const QuizInitial());

  QuizModel? _quiz;
  final Map<int, int> _answers = {};
  int _questionIndex = 0;
  int? _selectedAnswerId;
  Timer? _countdown;
  int? _remainingSeconds;

  Future<void> getQuiz(int? quizId) async {
    if (quizId == null) {
      safeEmit(QuizError(errorMsg: ErrorHandler.defaultMessage()));
      return;
    }

    safeEmit(const QuizLoading());

    final result = await _quizzesRepo.getQuizDetails(quizId: quizId);
    result.fold((failure) => safeEmit(QuizError(errorMsg: failure.message)), (
      quiz,
    ) {
      _quiz = quiz;
      _resetSession();

      if (quiz.questions.isEmpty) {
        safeEmit(const QuizEmpty());
        return;
      }

      _startCountdown(quiz);
      _emitQuestion();
    });
  }

  /// `time_limit` is in minutes and may be absent or zero, which means the quiz
  /// is untimed — no countdown is shown at all in that case.
  void _startCountdown(QuizModel quiz) {
    final minutes = quiz.timeLimit ?? 0;
    if (minutes <= 0) return;

    _remainingSeconds = minutes * 60;
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = (_remainingSeconds ?? 0) - 1;
      _remainingSeconds = remaining;

      if (remaining <= 0) {
        _finishOnTimeout();
        return;
      }

      _emitQuestion();
    });
  }

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
  }

  /// Time ran out: whatever the student has answered so far is submitted,
  /// including the answer selected on the question they were still on.
  void _finishOnTimeout() {
    _stopCountdown();
    _remainingSeconds = 0;

    final quiz = _quiz;
    if (quiz == null) return;

    _commitSelectedAnswer(quiz);

    if (_answers.isEmpty) {
      // Submitting an empty answer map is rejected by the backend, so there is
      // nothing to grade — the screen sends the student back instead.
      safeEmit(const QuizTimeExpired());
      return;
    }

    safeEmit(
      QuizCompleted(
        answers: Map<int, int>.from(_answers),
        questions: quiz.questions,
        isTimeUp: true,
      ),
    );
  }

  void _commitSelectedAnswer(QuizModel quiz) {
    final selectedAnswerId = _selectedAnswerId;
    if (selectedAnswerId == null) return;

    final questionId = quiz.questions[_questionIndex].id;
    if (questionId != null) {
      _answers[questionId] = selectedAnswerId;
    }
  }

  void selectAnswer(int? answerId) {
    if (answerId == null) return;

    // Freely changeable until the student moves on: there is nothing to reveal
    // any more, so locking a choice in place would only trap a mis-tap.
    _selectedAnswerId = answerId;
    _emitQuestion();
  }

  void goToNextQuestion() {
    final quiz = _quiz;
    final selectedAnswerId = _selectedAnswerId;
    if (quiz == null || selectedAnswerId == null) return;

    _commitSelectedAnswer(quiz);

    final isLastQuestion = _questionIndex >= quiz.questions.length - 1;
    if (isLastQuestion) {
      _stopCountdown();
      // Submitting is the result screen's job, so the student watches the
      // request run there instead of on the last question.
      safeEmit(
        QuizCompleted(
          answers: Map<int, int>.from(_answers),
          questions: quiz.questions,
        ),
      );
      return;
    }

    _questionIndex++;
    _selectedAnswerId = null;
    _emitQuestion();
  }

  void _resetSession() {
    _stopCountdown();
    _remainingSeconds = null;
    _answers.clear();
    _questionIndex = 0;
    _selectedAnswerId = null;
  }

  void _emitQuestion({bool isSubmitting = false}) {
    final quiz = _quiz;
    if (quiz == null || quiz.questions.isEmpty) return;

    safeEmit(
      QuizQuestionLoaded(
        question: quiz.questions[_questionIndex],
        questionIndex: _questionIndex,
        totalQuestions: quiz.questions.length,
        selectedAnswerId: _selectedAnswerId,
        remainingSeconds: _remainingSeconds,
        isSubmitting: isSubmitting,
      ),
    );
  }

  @override
  Future<void> close() {
    // A live timer would otherwise keep ticking into a closed cubit after the
    // student leaves mid-quiz.
    _stopCountdown();
    return super.close();
  }
}
