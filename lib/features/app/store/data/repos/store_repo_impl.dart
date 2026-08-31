import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/store_category_model.dart';
import '../models/store_product_model.dart';
import 'store_repo.dart';

class StoreRepoImpl implements StoreRepo {
  final ApiServices _apiServices;

  StoreRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<StoreCategoryModel>>> getCategories() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.categories);
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
  Future<Either<Failure, PagedResult<StoreProductModel>>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
  }) async {
    try {
      final resp = await _apiServices.get(
        endPoint: _productsEndpointWithFilters(
          categoryId: categoryId,
          search: search,
          page: page,
        ),
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

          return right(
            PagedResult(
              items: products,
              // Laravel paginator: the paging fields sit beside the list.
              pagination: PaginationModel.fromJson(
                paginationData is Map<String, dynamic> ? paginationData : null,
              ),
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

  String _productsEndpointWithFilters({
    int? categoryId,
    String? search,
    int page = 1,
  }) {
    final query = <String, String>{
      if (page > 1) 'page': page.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      // An empty `search` is the same as no search to the backend, so it is
      // dropped rather than sent as a blank filter.
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    if (query.isEmpty) return Urls.products;

    return Uri(path: Urls.products, queryParameters: query).toString();
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
