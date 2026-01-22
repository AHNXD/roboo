import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';

import 'login_repo.dart';

class LoginRepoIpml implements LoginRepo {
  final ApiServices apiServices;

  LoginRepoIpml(this.apiServices);
  @override
  Future<Either<Failure, String>> login(String pass, String phone) async {
    try {
      Map<String, dynamic> loginData = {
        "phone": phone,
        "password": pass,
      };
      var resp = await apiServices.post(endPoint: Urls.login, data: loginData);
      if (resp.statusCode == 200 && resp.data['status']) {
        CacheHelper.setString(
          key: 'token',
          value: resp.data['data']['user']['main_data']['token'],
        );
        CacheHelper.setString(
          key: 'role',
          value: resp.data['data']['user']['main_data']['role'].toString(),
        );
        isGuest = false;
        return right(resp.data['data']['user']['main_data']['role'].toString());
      }
      return left(
        resp.data['message'] ?? ServerFailure(ErrorHandler.defaultMessage()),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
