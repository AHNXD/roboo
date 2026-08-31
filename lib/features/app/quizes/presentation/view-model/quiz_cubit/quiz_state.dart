part of 'quiz_cubit.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

final class QuizInitial extends QuizState {
  const QuizInitial();
}

final class QuizLoading extends QuizState {
  const QuizLoading();
}

final class QuizEmpty extends QuizState {
  const QuizEmpty();
}

final class QuizQuestionLoaded extends QuizState {
  final QuestionModel question;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedAnswerId;

  /// Null when the quiz carries no `time_limit` — an untimed quiz shows no
  /// countdown rather than a frozen one.
  final int? remainingSeconds;

  final bool isSubmitting;

  const QuizQuestionLoaded({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswerId,
    this.remainingSeconds,
    this.isSubmitting = false,
  });

  bool get isLastQuestion => questionIndex >= totalQuestions - 1;

  bool get isTimed => remainingSeconds != null;

  /// The last minute, when the countdown turns urgent.
  bool get isRunningOut => (remainingSeconds ?? 61) <= 60;

  String get formattedTimeLeft {
    final total = remainingSeconds ?? 0;
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  List<Object?> get props => [
    question,
    questionIndex,
    totalQuestions,
    selectedAnswerId,
    remainingSeconds,
    isSubmitting,
  ];
}

/// The last question is answered. The screen navigates to the result screen,
/// which owns the submit request.
final class QuizCompleted extends QuizState {
  final Map<int, int> answers;

  /// Carried along so the result screen can turn `question_results` ids back
  /// into question and answer text without re-fetching the quiz.
  final List<QuestionModel> questions;

  /// True when the countdown ran out rather than the student finishing.
  final bool isTimeUp;

  const QuizCompleted({
    required this.answers,
    required this.questions,
    this.isTimeUp = false,
  });

  @override
  List<Object?> get props => [answers, questions, isTimeUp];
}

final class QuizError extends QuizState {
  final String errorMsg;

  const QuizError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}

/// The countdown ran out before a single answer was given. There is nothing to
/// grade, so the screen reports it and leaves.
final class QuizTimeExpired extends QuizState {
  const QuizTimeExpired();
}
