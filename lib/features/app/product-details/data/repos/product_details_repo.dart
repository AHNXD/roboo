import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/product_details_model.dart';

abstract class ProductDetailsRepo {
  Future<Either<Failure, ProductDetailsModel>> getProductDetails({
    required int productId,
  });
}
