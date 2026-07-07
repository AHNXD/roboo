import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../models/login_response_model.dart';
import 'token_repo.dart';

class TokenRepoIpml implements TokenRepo {
  final ApiServices apiServices;

  TokenRepoIpml(this.apiServices);
  @override
  Future<Either<Failure, LoginUserModel>> cheackToken() async {
    try {
      final resp = await apiServices.get(endPoint: Urls.authMe);
      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final data = resp.data['data'] is Map<String, dynamic>
            ? resp.data['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final userJson = data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : <String, dynamic>{};
        final user = LoginUserModel.fromJson(userJson);

        await CacheHelper.setString(
          key: 'user',
          value: jsonEncode(user.toJson()),
        );

        return right(user);
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
