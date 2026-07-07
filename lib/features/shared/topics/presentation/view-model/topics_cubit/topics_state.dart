part of 'topics_cubit.dart';

sealed class TopicsState extends Equatable {
  const TopicsState();

  @override
  List<Object?> get props => [];
}

final class TopicsInitial extends TopicsState {}

final class TopicsLoading extends TopicsState {}

final class TopicsEmpty extends TopicsState {}

final class TopicsLoaded extends TopicsState {
  final List<TopicModel> topics;

  const TopicsLoaded({required this.topics});

  @override
  List<Object?> get props => [topics];
}

final class TopicsError extends TopicsState {
  final String errorMsg;

  const TopicsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
