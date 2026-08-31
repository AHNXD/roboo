import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../models/login_response_model.dart';

import 'login_repo.dart';

class LoginRepoIpml implements LoginRepo {
  final ApiServices apiServices;

  LoginRepoIpml(this.apiServices);

  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      // The API takes the device token on the login request itself, which is
      // the only channel available before a session exists.
      final fcmToken = _cachedFcmToken();

      final resp = await apiServices.post(
        endPoint: Urls.authLogin,
        data: <String, dynamic>{
          'email': email,
          'password': password,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      return _sessionFromResponse(resp.statusCode, resp.data, fcmToken);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, LoginResponseModel>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final fcmToken = _cachedFcmToken();

      final resp = await apiServices.post(
        endPoint: Urls.authGoogle,
        data: <String, dynamic>{
          'token': idToken,
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );

      return _sessionFromResponse(resp.statusCode, resp.data, fcmToken);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  String? _cachedFcmToken() {
    final token = CacheHelper.getData(key: 'fcm_token')?.toString();
    return (token == null || token.isEmpty) ? null : token;
  }

  /// Shared by both sign-in routes: they return the same envelope, so they
  /// establish the session the same way.
  Future<Either<Failure, LoginResponseModel>> _sessionFromResponse(
    int? statusCode,
    dynamic data,
    String? fcmToken,
  ) async {
    if (statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['success'] == true) {
      final loginResponse = LoginResponseModel.fromJson(data);

      // An unverified account is a valid login that simply cannot enter the
      // app yet. No token is cached — `auth/verify-code` issues its own once
      // the OTP is accepted.
      if (loginResponse.mustVerify) {
        return right(loginResponse);
      }

      if (loginResponse.token.isEmpty) {
        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      await CacheHelper.setString(key: 'token', value: loginResponse.token);
      await CacheHelper.setString(
        key: 'user',
        value: jsonEncode(loginResponse.user.toJson()),
      );
      // Sent with this request, so no follow-up profile call is needed.
      if (fcmToken != null) {
        await CacheHelper.setString(key: 'fcm_token_synced', value: fcmToken);
      }
      isGuest = false;

      return right(loginResponse);
    }

    return left(
      ServerFailure(
        data is Map<String, dynamic>
            ? data['message']?.toString() ?? ErrorHandler.defaultMessage()
            : ErrorHandler.defaultMessage(),
      ),
    );
  }
}
