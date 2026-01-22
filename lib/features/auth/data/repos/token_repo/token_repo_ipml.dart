import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../models/user_model.dart';
import 'token_repo.dart';

class TokenRepoIpml implements TokenRepo {
  final ApiServices apiServices;

  TokenRepoIpml(this.apiServices);
  @override
  Future<Either<Failure, UserModel>> cheackToken() async {
    try {
      var resp = await apiServices.get(endPoint: Urls.getProfile);
      if (resp.statusCode == 200 && resp.data['success']) {
        return right(UserModel.fromJson(resp.data['data']));
      }
      return left(
          resp.data['message'] ?? ServerFailure(ErrorHandler.defaultMessage()));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
