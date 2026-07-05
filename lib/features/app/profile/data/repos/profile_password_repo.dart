import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/profile_password_update_response_model.dart';

abstract class ProfilePasswordRepo {
  Future<Either<Failure, String>> requestPasswordUpdateCode();

  Future<Either<Failure, ProfilePasswordUpdateResponseModel>> updatePassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  });
}
