import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';

abstract class LogoutRepo {
  Future<Either<Failure, void>> logout();

  /// Permanently deletes the account. The backend revokes every token, so the
  /// local session is cleared exactly as it is on logout.
  Future<Either<Failure, void>> deleteAccount();
}
