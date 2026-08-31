part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final List<CourseModel> courses;
  final List<MyCourseModel> myCourses;

  const HomeLoaded({required this.courses, required this.myCourses});

  @override
  List<Object?> get props => [courses, myCourses];
}

final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

final class HomeError extends HomeState {
  final String errorMsg;

  const HomeError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
