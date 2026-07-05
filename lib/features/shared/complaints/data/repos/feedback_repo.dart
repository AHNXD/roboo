import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/feedback_request_model.dart';
import '../models/feedback_response_model.dart';

abstract class FeedbackRepo {
  Future<Either<Failure, FeedbackResponseModel>> submitFeedback(
    FeedbackRequestModel request,
  );
}
