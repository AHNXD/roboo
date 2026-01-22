import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';

abstract class ResetPasswordRepo {
  Future<Either<Failure, String>> resetPassword({required String phone});
  Future<Either<Failure, String>> verifyResetPassword({
    required String phone,
    required String code,
    required String password,
  });
  Future<Either<Failure, void>> resendCode({required String phone});
}
