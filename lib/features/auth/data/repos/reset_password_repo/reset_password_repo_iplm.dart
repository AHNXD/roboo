import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../models/login_response_model.dart';
import 'reset_password_repo.dart';

class ResetPasswordRepoImpl implements ResetPasswordRepo {
  final ApiServices _apiServices;

  ResetPasswordRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, String>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authForgotPassword,
        data: {"email": email},
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

  @override
  Future<Either<Failure, LoginResponseModel>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authResetPassword,
        data: {
          "email": email,
          "code": code,
          "password": password,
          "password_confirmation": passwordConfirmation,
        },
      );

      if (resp.statusCode == 200 && resp.data["success"] == true) {
        final resetResponse = LoginResponseModel.fromJson(resp.data);

        if (resetResponse.token.isEmpty) {
          return left(ServerFailure(ErrorHandler.defaultMessage()));
        }

        await CacheHelper.setString(key: 'token', value: resetResponse.token);
        await CacheHelper.setString(
          key: 'user',
          value: jsonEncode(resetResponse.user.toJson()),
        );
        isGuest = false;

        return right(resetResponse);
      }

      return left(
        ServerFailure(
          resp.data["message"]?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
