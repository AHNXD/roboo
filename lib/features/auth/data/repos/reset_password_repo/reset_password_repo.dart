import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../models/login_response_model.dart';

abstract class ResetPasswordRepo {
  Future<Either<Failure, String>> requestPasswordReset({required String email});

  Future<Either<Failure, LoginResponseModel>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  });
}
