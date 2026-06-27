import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failuer.dart';
import '../../models/login_response_model.dart';

abstract class TokenRepo {
  Future<Either<Failure, LoginUserModel>> cheackToken();
}
