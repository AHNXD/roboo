import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failuer.dart';
import '../../models/user_model.dart';

abstract class TokenRepo {
  Future<Either<Failure, UserModel>> cheackToken();
}
