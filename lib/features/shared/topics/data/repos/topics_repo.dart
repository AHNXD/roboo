import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/topic_model.dart';

abstract class TopicsRepo {
  Future<Either<Failure, List<TopicModel>>> getTopics();
}
