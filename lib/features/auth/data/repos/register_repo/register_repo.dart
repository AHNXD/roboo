import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../models/user_model.dart';

abstract class RegisterRepo {
  Future<Either<Failure, UserModel>> register(
    Map<String, dynamic> registerData,
  );
}
