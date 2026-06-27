import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../models/login_response_model.dart';
import '../../models/register_request_model.dart';
import '../../models/register_response_model.dart';

abstract class RegisterRepo {
  Future<Either<Failure, RegisterResponseModel>> register(
    RegisterRequestModel request,
  );

  Future<Either<Failure, LoginResponseModel>> verifyAccount({
    required String email,
    required String code,
  });

  Future<Either<Failure, String>> resendVerification({required String email});
}
