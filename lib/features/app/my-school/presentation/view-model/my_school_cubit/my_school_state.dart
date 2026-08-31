part of 'my_school_cubit.dart';

sealed class MySchoolState extends Equatable {
  const MySchoolState();

  @override
  List<Object?> get props => [];
}

final class MySchoolInitial extends MySchoolState {
  const MySchoolInitial();
}

final class MySchoolLoading extends MySchoolState {
  const MySchoolLoading();
}

/// The student has not redeemed an enrolment coupon yet.
final class MySchoolNotEnrolled extends MySchoolState {
  const MySchoolNotEnrolled();
}

final class MySchoolRedeeming extends MySchoolState {
  const MySchoolRedeeming();
}

/// Transient: announced as a message, a real state follows immediately.
final class MySchoolRedeemSuccess extends MySchoolState {
  const MySchoolRedeemSuccess();
}

/// Transient: the student stays on the not-enrolled screen.
final class MySchoolRedeemError extends MySchoolState {
  final String errorMsg;

  const MySchoolRedeemError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}

final class MySchoolLoaded extends MySchoolState {
  final EnrollmentModel enrollment;
  final List<HomeworkModel> homework;

  /// Another page exists on the server.
  final bool hasMore;

  /// That next page is being fetched right now.
  final bool isLoadingMore;

  const MySchoolLoaded({
    required this.enrollment,
    required this.homework,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [enrollment, homework, hasMore, isLoadingMore];
}

final class MySchoolError extends MySchoolState {
  final String errorMsg;

  const MySchoolError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
