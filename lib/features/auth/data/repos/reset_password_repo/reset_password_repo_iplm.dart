import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import 'reset_password_repo.dart';

class ResetPasswordRepoImpl implements ResetPasswordRepo {
  final ApiServices _apiServices;

  ResetPasswordRepoImpl(this._apiServices);
  @override
  Future<Either<Failure, String>> resetPassword({required String phone}) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.forgetPassword,
        data: {"phone": phone},
      );

      if (resp.statusCode == 200 && resp.data['success']) {
        return Right(resp.data['data']['phone']);
      } else {
        return Left(ServerFailure(
            resp.data['message'] ?? ErrorHandler.defaultMessage()));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyResetPassword({
    required String phone,
    required String code,
    required String password,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.verfiResetPassword,
        data: {
          "phone": phone,
          "code": code,
          "password": password,
        },
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return Right(response.data["message"]);
      }
      return Left(ServerFailure(
          response.data["message"] ?? ErrorHandler.defaultMessage()));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode({required String phone}) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.resendCode,
        data: {"phone": phone},
      );

      if (response.data["success"] == true) {
        return Right(null);
      } else {
        return Left(ServerFailure(
            response.data["message"] ?? ErrorHandler.defaultMessage()));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
