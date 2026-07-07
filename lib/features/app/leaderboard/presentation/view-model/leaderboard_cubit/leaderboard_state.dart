part of 'leaderboard_cubit.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

final class LeaderboardInitial extends LeaderboardState {}

final class LeaderboardLoading extends LeaderboardState {}

final class LeaderboardEmpty extends LeaderboardState {}

final class LeaderboardLoaded extends LeaderboardState {
  final List<Competitor> competitors;

  const LeaderboardLoaded({required this.competitors});

  @override
  List<Object?> get props => [competitors];
}

final class LeaderboardError extends LeaderboardState {
  final String errorMsg;

  const LeaderboardError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
