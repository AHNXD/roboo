import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/favorite_product_model.dart';
import '../models/favorite_toggle_response_model.dart';

abstract class FavoritesRepo {
  Future<Either<Failure, List<FavoriteProductModel>>> getFavorites();

  Future<Either<Failure, FavoriteToggleResponseModel>> toggleFavorite({
    required int productId,
  });
}
