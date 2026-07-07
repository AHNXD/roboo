import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/competitor_model.dart';
import 'leaderboard_repo.dart';

class LeaderboardRepoImpl implements LeaderboardRepo {
  final ApiServices _apiServices;

  static const String _leaderboardEndpoint = 'leaderboard';

  LeaderboardRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<Competitor>>> getLeaderboard() async {
    try {
      final resp = await _apiServices.get(endPoint: _leaderboardEndpoint);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final leaderboard = data is Map<String, dynamic>
            ? data['leaderboard']
            : null;

        if (leaderboard is List) {
          final competitors = leaderboard
              .whereType<Map<String, dynamic>>()
              .toList()
              .asMap()
              .entries
              .map(
                (entry) =>
                    Competitor.fromJson(entry.value, rank: entry.key + 1),
              )
              .toList();
          return right(competitors);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(
        ServerFailure(
          responseData is Map<String, dynamic>
              ? responseData['message']?.toString() ??
                    ErrorHandler.defaultMessage()
              : ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
