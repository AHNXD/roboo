import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';


abstract class TempRepo {
  Future<Either<Failure, bool>> tempFunction();
}
