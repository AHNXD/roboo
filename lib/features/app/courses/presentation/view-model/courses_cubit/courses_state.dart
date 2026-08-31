part of 'courses_cubit.dart';

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesInitial extends CoursesState {}

final class CoursesLoading extends CoursesState {}

final class CoursesContentLoading extends CoursesState {
  final List<TopicModel> topics;
  final int selectedIndex;

  const CoursesContentLoading({
    required this.topics,
    required this.selectedIndex,
  });

  @override
  List<Object?> get props => [topics, selectedIndex];
}

final class CoursesContentError extends CoursesState {
  final List<TopicModel> topics;
  final int selectedIndex;
  final String errorMsg;

  const CoursesContentError({
    required this.topics,
    required this.selectedIndex,
    required this.errorMsg,
  });

  @override
  List<Object?> get props => [topics, selectedIndex, errorMsg];
}

final class CoursesLoaded extends CoursesState {
  final List<TopicModel> topics;
  final List<CourseModel> courses;
  final int selectedIndex;

  /// Another page exists on the server.
  final bool hasMore;

  /// That next page is being fetched right now.
  final bool isLoadingMore;

  const CoursesLoaded({
    required this.topics,
    required this.courses,
    this.selectedIndex = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    topics,
    courses,
    selectedIndex,
    hasMore,
    isLoadingMore,
  ];
}

final class CoursesEmpty extends CoursesState {
  final List<TopicModel> topics;
  final int selectedIndex;

  const CoursesEmpty({required this.topics, this.selectedIndex = 0});

  @override
  List<Object?> get props => [topics, selectedIndex];
}

final class CoursesError extends CoursesState {
  final String errorMsg;

  const CoursesError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
