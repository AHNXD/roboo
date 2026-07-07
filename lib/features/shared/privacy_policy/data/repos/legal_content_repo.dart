import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/legal_content_model.dart';

abstract class LegalContentRepo {
  Future<Either<Failure, LegalContentModel>> getPrivacyPolicy();
  Future<Either<Failure, LegalContentModel>> getTermsOfUse();
}
