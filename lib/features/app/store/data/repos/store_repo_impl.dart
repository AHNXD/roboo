import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/store_category_model.dart';
import '../models/store_product_model.dart';
import 'store_repo.dart';

class StoreRepoImpl implements StoreRepo {
  final ApiServices _apiServices;

  static const String _categoriesEndpoint = 'categories';
  static const String _productsEndpoint = 'products';

  StoreRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<StoreCategoryModel>>> getCategories() async {
    try {
      final resp = await _apiServices.get(endPoint: _categoriesEndpoint);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        if (data is List) {
          final categories = data
              .whereType<Map<String, dynamic>>()
              .map(StoreCategoryModel.fromJson)
              .toList();
          return right(categories);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<StoreProductModel>>> getProducts({
    int? categoryId,
  }) async {
    try {
      final resp = await _apiServices.get(
        endPoint: _productsEndpointWithFilters(categoryId: categoryId),
      );
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
              .map(StoreProductModel.fromJson)
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

  String _productsEndpointWithFilters({int? categoryId}) {
    if (categoryId == null) return _productsEndpoint;

    return Uri(
      path: _productsEndpoint,
      queryParameters: {'category_id': categoryId.toString()},
    ).toString();
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
