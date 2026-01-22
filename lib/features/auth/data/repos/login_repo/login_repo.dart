import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failuer.dart';

abstract class LoginRepo {
  Future<Either<Failure, String>> login(String pass, String phone);
}
