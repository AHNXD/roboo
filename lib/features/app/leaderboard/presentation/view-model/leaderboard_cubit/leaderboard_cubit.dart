import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/competitor_model.dart';
import '../../../data/repos/leaderboard_repo.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final LeaderboardRepo _leaderboardRepo;

  LeaderboardCubit(this._leaderboardRepo) : super(LeaderboardInitial());

  Future<void> getLeaderboard() async {
    emit(LeaderboardLoading());
    final result = await _leaderboardRepo.getLeaderboard();
    result.fold(
      (failure) => emit(LeaderboardError(errorMsg: failure.message)),
      (competitors) => competitors.isEmpty
          ? emit(LeaderboardEmpty())
          : emit(LeaderboardLoaded(competitors: competitors)),
    );
  }
}
