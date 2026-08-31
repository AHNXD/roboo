part of 'quizzes_cubit.dart';

sealed class QuizzesState extends Equatable {
  const QuizzesState();

  @override
  List<Object?> get props => [];
}

final class QuizzesInitial extends QuizzesState {
  const QuizzesInitial();
}

final class QuizzesLoading extends QuizzesState {
  const QuizzesLoading();
}

final class QuizzesLoaded extends QuizzesState {
  final List<TopicModel> topics;
  final List<QuizModel> quizzes;
  final int selectedIndex;

  const QuizzesLoaded({
    required this.topics,
    required this.quizzes,
    this.selectedIndex = 0,
  });

  @override
  List<Object?> get props => [topics, quizzes, selectedIndex];
}

final class QuizzesEmpty extends QuizzesState {
  final List<TopicModel> topics;
  final int selectedIndex;

  const QuizzesEmpty({required this.topics, this.selectedIndex = 0});

  @override
  List<Object?> get props => [topics, selectedIndex];
}

final class QuizzesError extends QuizzesState {
  final String errorMsg;

  const QuizzesError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
