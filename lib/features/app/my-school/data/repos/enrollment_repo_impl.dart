import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/enrollment_model.dart';
import 'enrollment_repo.dart';

class EnrollmentRepoImpl implements EnrollmentRepo {
  final ApiServices _apiServices;

  EnrollmentRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, EnrollmentModel>> getEnrollment() async {
    try {
      final response = await _apiServices.get(endPoint: Urls.enrollment);

      return _parseEnrollment(response.statusCode, response.data);
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, EnrollmentModel>> redeemCode({
    required String code,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.enrollmentRedeem,
        data: {'code': code},
      );

      return _parseEnrollment(response.statusCode, response.data);
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  Either<Failure, EnrollmentModel> _parseEnrollment(
    int? statusCode,
    dynamic responseData,
  ) {
    if ((statusCode == 200 || statusCode == 201) &&
        responseData is Map<String, dynamic> &&
        responseData['success'] == true) {
      final data = responseData['data'];

      if (data is Map<String, dynamic>) {
        return right(EnrollmentModel.fromJson(data));
      }

      return left(ServerFailure(ErrorHandler.defaultMessage()));
    }

    return left(_serverFailure(responseData));
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
