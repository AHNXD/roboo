import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failuer.dart';
import '../../models/login_response_model.dart';

abstract class LoginRepo {
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  });

  /// Exchanges a Google ID token for a Roboo session.
  Future<Either<Failure, LoginResponseModel>> loginWithGoogle({
    required String idToken,
  });
}
