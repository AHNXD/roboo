import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import 'logout_repo.dart';

class LogoutRepoIplm implements LogoutRepo {
  final ApiServices _apiServices;

  LogoutRepoIplm(this._apiServices);
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      var resp = await _apiServices.post(endPoint: Urls.logout, data: {});
      if (resp.statusCode == 200 || resp.data["status"] == true) {
        CacheHelper.removeData(key: "token");
        isGuest = true;
        return right(null);
      }
      return left(ServerFailure(ErrorHandler.defaultMessage()));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
