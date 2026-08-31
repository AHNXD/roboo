import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/cart_model.dart';
import '../models/cart_checkout_response_model.dart';
import 'cart_repo.dart';

class CartRepoImpl implements CartRepo {
  final ApiServices _apiServices;

  CartRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, CartModel>> getCart() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.cart);
      return _cartResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CartModel>> addItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.cartItems,
        data: {'product_id': productId, 'quantity': quantity},
      );
      return _cartResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CartModel>> updateItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.cartItemsUpdate,
        data: {'product_id': productId, 'quantity': quantity},
      );
      return _cartResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CartModel>> removeItem({
    required int productId,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.cartItemsRemove,
        data: {'product_id': productId},
      );
      return _cartResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CartModel>> clearCart() async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.cartClear,
        data: const {},
      );
      return _cartResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CartCheckoutResponseModel>> checkout() async {
    try {
      // The order is built from the server-side cart, so the body stays empty.
      // The Postman example shows an `items` array, but that example is stale:
      // posting with and without `items` against an empty cart returns the very
      // same 422 `{"errors":{"cart":["Your cart is empty."]}}`, so the field is
      // ignored (verified against the live API on 2026-08-29). Do not "fix"
      // this to match the collection.
      final resp = await _apiServices.post(
        endPoint: Urls.orders,
        data: const {},
      );
      final responseData = resp.data;

      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(
            CartCheckoutResponseModel.fromJson(
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

  Either<Failure, CartModel> _cartResultFromResponse(
    int? statusCode,
    dynamic responseData,
  ) {
    if (statusCode == 200 &&
        responseData is Map<String, dynamic> &&
        responseData['success'] == true) {
      final data = responseData['data'];

      if (data is Map<String, dynamic>) {
        return right(CartModel.fromJson(data));
      }

      return left(ServerFailure(ErrorHandler.defaultMessage()));
    }

    return left(_serverFailure(responseData));
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
