import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../models/login_response_model.dart';

import 'login_repo.dart';

class LoginRepoIpml implements LoginRepo {
  final ApiServices apiServices;

  static const String _loginEndpoint = 'auth/login';

  LoginRepoIpml(this.apiServices);
  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = <String, dynamic>{'email': email, 'password': password};

      final resp = await apiServices.post(
        endPoint: _loginEndpoint,
        data: loginData,
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final loginResponse = LoginResponseModel.fromJson(resp.data);

        if (loginResponse.token.isEmpty) {
          return left(ServerFailure(ErrorHandler.defaultMessage()));
        }

        await CacheHelper.setString(key: 'token', value: loginResponse.token);
        isGuest = false;

        return right(loginResponse);
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
