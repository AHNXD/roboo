import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/store_category_model.dart';
import '../models/store_product_model.dart';

abstract class StoreRepo {
  Future<Either<Failure, List<StoreCategoryModel>>> getCategories();

  /// [search] matches the product's English *and* Arabic name, case
  /// insensitively, and combines with [categoryId] as AND. [page] is 1-based;
  /// the page size is fixed at 25 by the backend.
  Future<Either<Failure, PagedResult<StoreProductModel>>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
  });
}
