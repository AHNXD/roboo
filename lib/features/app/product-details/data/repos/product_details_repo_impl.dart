import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/product_details_model.dart';
import 'product_details_repo.dart';

class ProductDetailsRepoImpl implements ProductDetailsRepo {
  final ApiServices _apiServices;

  ProductDetailsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, ProductDetailsModel>> getProductDetails({
    required int productId,
  }) async {
    try {
      final resp = await _apiServices.get(
        endPoint: Urls.productDetails(productId),
      );
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(ProductDetailsModel.fromJson(data));
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
