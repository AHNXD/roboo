import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/feedback_request_model.dart';
import '../models/feedback_response_model.dart';
import 'feedback_repo.dart';

class FeedbackRepoImpl implements FeedbackRepo {
  final ApiServices _apiServices;

  static const String _feedbacksEndpoint = 'feedbacks';

  FeedbackRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, FeedbackResponseModel>> submitFeedback(
    FeedbackRequestModel request,
  ) async {
    try {
      final resp = await _apiServices.post(
        endPoint: _feedbacksEndpoint,
        data: request.toJson(),
      );
      final responseData = resp.data;

      if (resp.statusCode == 201 &&
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
