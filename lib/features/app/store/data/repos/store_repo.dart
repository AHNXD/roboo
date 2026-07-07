import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/store_category_model.dart';
import '../models/store_product_model.dart';

abstract class StoreRepo {
  Future<Either<Failure, List<StoreCategoryModel>>> getCategories();

  Future<Either<Failure, List<StoreProductModel>>> getProducts({
    int? categoryId,
  });
}
