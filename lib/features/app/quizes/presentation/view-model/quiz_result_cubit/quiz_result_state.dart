part of 'quiz_result_cubit.dart';

sealed class QuizResultState extends Equatable {
  const QuizResultState();

  @override
  List<Object?> get props => [];
}

final class QuizResultInitial extends QuizResultState {
  const QuizResultInitial();
}

final class QuizResultLoading extends QuizResultState {
  const QuizResultLoading();
}

final class QuizResultLoaded extends QuizResultState {
  final QuizResultModel result;

  const QuizResultLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

final class QuizResultError extends QuizResultState {
  final String errorMsg;

  const QuizResultError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
