part of 'feedback_cubit.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

final class FeedbackInitial extends FeedbackState {}

final class FeedbackSubmitting extends FeedbackState {}

final class FeedbackSubmitSuccess extends FeedbackState {
  final FeedbackResponseModel response;

  const FeedbackSubmitSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

final class FeedbackError extends FeedbackState {
  final String errorMsg;

  const FeedbackError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
