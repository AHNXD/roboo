import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/favorite_product_model.dart';
import '../models/favorite_toggle_response_model.dart';
import 'favorites_repo.dart';

class FavoritesRepoImpl implements FavoritesRepo {
  final ApiServices _apiServices;

  FavoritesRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<FavoriteProductModel>>> getFavorites() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.favorites);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final paginationData = responseData['data'];
        final data = paginationData is Map<String, dynamic>
            ? paginationData['data']
            : null;

        if (data is List) {
          final products = data
              .whereType<Map<String, dynamic>>()
              .map(FavoriteProductModel.fromJson)
              .toList();
          return right(products);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, FavoriteToggleResponseModel>> toggleFavorite({
    required int productId,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.productFavorite,
        data: {
          'product_ids': [productId],
        },
      );
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(
            FavoriteToggleResponseModel.fromJson(
              json: data,
              message: responseData['message']?.toString() ?? '',
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
