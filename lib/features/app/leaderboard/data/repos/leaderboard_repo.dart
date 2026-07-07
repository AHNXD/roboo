import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/competitor_model.dart';

abstract class LeaderboardRepo {
  Future<Either<Failure, List<Competitor>>> getLeaderboard();
}
