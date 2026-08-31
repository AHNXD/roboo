import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRepo {
  Future<Either<Failure, EnrollmentModel>> getEnrollment();

  /// Joins the section the coupon belongs to. Single use — a second redemption
  /// of the same code answers 422.
  Future<Either<Failure, EnrollmentModel>> redeemCode({required String code});
}
