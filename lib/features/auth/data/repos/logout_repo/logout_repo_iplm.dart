import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import 'logout_repo.dart';

class LogoutRepoIplm implements LogoutRepo {
  final ApiServices _apiServices;

  static const String _logoutEndpoint = 'auth/logout';

  LogoutRepoIplm(this._apiServices);
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final resp = await _apiServices.post(endPoint: _logoutEndpoint, data: {});

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

  Future<void> _clearLocalAuth() async {
    await CacheHelper.removeData(key: "token");
    await CacheHelper.removeData(key: "user");
    isGuest = true;
  }
}
