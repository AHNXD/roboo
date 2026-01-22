import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';

abstract class LogoutRepo {
  Future<Either<Failure, void>> logout();
}
