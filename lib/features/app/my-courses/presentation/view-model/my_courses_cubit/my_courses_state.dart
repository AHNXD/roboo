part of 'my_courses_cubit.dart';

sealed class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object?> get props => [];
}

final class MyCoursesInitial extends MyCoursesState {
  const MyCoursesInitial();
}

final class MyCoursesLoading extends MyCoursesState {
  const MyCoursesLoading();
}

final class MyCoursesLoaded extends MyCoursesState {
  final List<TopicModel> topics;
  final List<MyCourseModel> courses;
  final int selectedIndex;

  const MyCoursesLoaded({
    required this.topics,
    required this.courses,
    this.selectedIndex = 0,
  });

  @override
  List<Object?> get props => [topics, courses, selectedIndex];
}

final class MyCoursesEmpty extends MyCoursesState {
  final List<TopicModel> topics;
  final int selectedIndex;

  const MyCoursesEmpty({required this.topics, this.selectedIndex = 0});

  @override
  List<Object?> get props => [topics, selectedIndex];
}

final class MyCoursesError extends MyCoursesState {
  final String errorMsg;

  const MyCoursesError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
