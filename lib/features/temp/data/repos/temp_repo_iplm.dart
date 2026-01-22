import 'package:dartz/dartz.dart';
import '../../../../core/Api_services/api_services.dart';
import '../../../../core/Api_services/urls.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failuer.dart';
import 'temp_repo.dart';

class TempRepoIplm implements TempRepo {
  final ApiServices _apiServices;

  TempRepoIplm(this._apiServices);

  @override
  Future<Either<Failure, bool>> tempFunction() async {
    try {
      var resp = await _apiServices.get(endPoint: Urls.getProfile);

      if (resp.statusCode == 200 && resp.data['status'] == true) {
        return right(true);
      }

      return left(
        ServerFailure(resp.data['message'] ?? ErrorHandler.defaultMessage()),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
