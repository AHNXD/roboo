import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../../../../core/utils/google_auth_service.dart';
import '../../../../../core/utils/services_locater.dart';
import 'logout_repo.dart';

class LogoutRepoIplm implements LogoutRepo {
  final ApiServices _apiServices;

  LogoutRepoIplm(this._apiServices);
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final resp = await _apiServices.post(endPoint: Urls.authLogout, data: {});

      final data = resp.data;
      final isSuccessEnvelope =
          data is Map<String, dynamic> && data['success'] == true;
      final isSuccessfulStatus =
          resp.statusCode == 200 || resp.statusCode == 204;
      final isInvalidToken = resp.statusCode == 401;

      if (isSuccessfulStatus || isSuccessEnvelope || isInvalidToken) {
        await _clearLocalAuth();
        return right(null);
      }

      return left(
        ServerFailure(
          data is Map<String, dynamic>
              ? data['message']?.toString() ?? ErrorHandler.defaultMessage()
              : ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final resp = await _apiServices.delete(endPoint: Urls.authProfile);

      final data = resp.data;
      final isSuccessEnvelope =
          data is Map<String, dynamic> && data['success'] == true;
      final isSuccessfulStatus =
          resp.statusCode == 200 || resp.statusCode == 204;

      if (isSuccessfulStatus || isSuccessEnvelope) {
        await _clearLocalAuth();
        return right(null);
      }

      return left(
        ServerFailure(
          data is Map<String, dynamic>
              ? data['message']?.toString() ?? ErrorHandler.defaultMessage()
              : ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  Future<void> _clearLocalAuth() async {
    // Otherwise the next Google sign-in silently reuses the same account
    // instead of showing the chooser.
    await getit.get<GoogleAuthService>().signOut();
    await CacheHelper.removeData(key: "token");
    await CacheHelper.removeData(key: "user");
    isGuest = true;
  }
}
