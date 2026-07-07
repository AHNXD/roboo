import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../models/login_response_model.dart';
import '../../models/register_request_model.dart';
import '../../models/register_response_model.dart';
import 'register_repo.dart';

class RegisterRepoIplm implements RegisterRepo {
  final ApiServices _apiServices;

  RegisterRepoIplm(this._apiServices);

  @override
  Future<Either<Failure, RegisterResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authRegister,
        data: request.toJson(),
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        return right(RegisterResponseModel.fromJson(resp.data));
      }

      return left(
        ServerFailure(
          resp.data['message']?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, LoginResponseModel>> verifyAccount({
    required String email,
    required String code,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authVerifyCode,
        data: {'email': email, 'code': code},
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final verifyResponse = LoginResponseModel.fromJson(resp.data);

        if (verifyResponse.token.isEmpty) {
          return left(ServerFailure(ErrorHandler.defaultMessage()));
        }

        await CacheHelper.setString(key: 'token', value: verifyResponse.token);
        await CacheHelper.setString(
          key: 'user',
          value: jsonEncode(verifyResponse.user.toJson()),
        );
        isGuest = false;

        return right(verifyResponse);
      }

      return left(
        ServerFailure(
          resp.data['message']?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> resendVerification({
    required String email,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authResendVerification,
        data: {'email': email},
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        return right(resp.data['message']?.toString() ?? '');
      }

      return left(
        ServerFailure(
          resp.data['message']?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
