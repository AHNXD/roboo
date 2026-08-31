part of 'homework_details_cubit.dart';

sealed class HomeworkDetailsState extends Equatable {
  const HomeworkDetailsState();

  @override
  List<Object?> get props => [];
}

final class HomeworkDetailsInitial extends HomeworkDetailsState {
  const HomeworkDetailsInitial();
}

final class HomeworkDetailsLoading extends HomeworkDetailsState {
  const HomeworkDetailsLoading();
}

final class HomeworkDetailsLoaded extends HomeworkDetailsState {
  final HomeworkModel homework;
  final Map<int, int> selectedAnswers;
  final bool isSubmitting;

  const HomeworkDetailsLoaded({
    required this.homework,
    required this.selectedAnswers,
    this.isSubmitting = false,
  });

  bool get canSubmitMcq =>
      homework.isAnswerable &&
      homework.questions.isNotEmpty &&
      selectedAnswers.length == homework.questions.length;

  @override
  List<Object?> get props => [homework, selectedAnswers, isSubmitting];
}

/// Transient: announced as a message, the reloaded homework follows.
final class HomeworkSubmitSuccess extends HomeworkDetailsState {
  const HomeworkSubmitSuccess();
}

/// Transient: the student stays on the homework with their answers intact.
final class HomeworkSubmitError extends HomeworkDetailsState {
  final String errorMsg;

  const HomeworkSubmitError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}

final class HomeworkDetailsError extends HomeworkDetailsState {
  final String errorMsg;

  const HomeworkDetailsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
