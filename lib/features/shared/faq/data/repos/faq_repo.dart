import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/faq_model.dart';

abstract class FaqRepo {
  /// [page] is 1-based; the backend fixes the page size at 25.
  Future<Either<Failure, PagedResult<FaqModel>>> getFaqs({int page = 1});
}
