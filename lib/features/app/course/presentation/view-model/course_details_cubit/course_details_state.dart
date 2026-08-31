part of 'course_details_cubit.dart';

sealed class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

final class CourseDetailsInitial extends CourseDetailsState {
  const CourseDetailsInitial();
}

final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

final class CourseDetailsLoaded extends CourseDetailsState {
  final CourseDetailsModel course;
  final bool isUnlocking;

  const CourseDetailsLoaded({required this.course, this.isUnlocking = false});

  @override
  List<Object?> get props => [course, isUnlocking];
}

/// Transient: shown as a message, the loaded state follows immediately.
final class CourseDetailsCouponApplied extends CourseDetailsState {
  const CourseDetailsCouponApplied();
}

/// Transient: a failed action keeps the user on the loaded course.
final class CourseDetailsActionError extends CourseDetailsState {
  final String errorMsg;

  const CourseDetailsActionError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}

final class CourseDetailsError extends CourseDetailsState {
  final String errorMsg;

  const CourseDetailsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
