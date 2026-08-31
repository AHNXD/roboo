import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/feedback_request_model.dart';
import '../models/feedback_response_model.dart';
import 'feedback_repo.dart';

class FeedbackRepoImpl implements FeedbackRepo {
  final ApiServices _apiServices;

  FeedbackRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, FeedbackResponseModel>> submitFeedback(
    FeedbackRequestModel request,
  ) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.feedbacks,
        data: request.toJson(),
      );
      final responseData = resp.data;

      // The collection's example answers 201; accept 200 too so a controller
      // that returns a plain OK is not reported to the user as a failure.
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(FeedbackResponseModel.fromJson(responseData));
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
