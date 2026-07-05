import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/faq_model.dart';

abstract class FaqRepo {
  Future<Either<Failure, List<FaqModel>>> getFaqs();
}
