import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../models/profile_password_update_response_model.dart';
import 'profile_password_repo.dart';

class ProfilePasswordRepoImpl implements ProfilePasswordRepo {
  final ApiServices _apiServices;

  static const String _requestPasswordUpdateEndpoint =
      'auth/request-password-update';
  static const String _updatePasswordEndpoint = 'auth/update-password';

  ProfilePasswordRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, String>> requestPasswordUpdateCode() async {
    try {
      final resp = await _apiServices.post(
        endPoint: _requestPasswordUpdateEndpoint,
        data: <String, dynamic>{},
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
  Future<Either<Failure, ProfilePasswordUpdateResponseModel>> updatePassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: _updatePasswordEndpoint,
        data: {
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final response = ProfilePasswordUpdateResponseModel.fromJson(resp.data);

        if (response.token.isEmpty) {
          return left(ServerFailure(ErrorHandler.defaultMessage()));
        }

        await CacheHelper.setString(key: 'token', value: response.token);
        await CacheHelper.setString(
          key: 'user',
          value: jsonEncode(response.user.toJson()),
        );
        isGuest = false;

        return right(response);
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
