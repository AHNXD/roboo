import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/cart_model.dart';
import '../models/cart_checkout_response_model.dart';

abstract class CartRepo {
  Future<Either<Failure, CartModel>> getCart();

  Future<Either<Failure, CartModel>> addItem({
    required int productId,
    required int quantity,
  });

  Future<Either<Failure, CartModel>> updateItem({
    required int productId,
    required int quantity,
  });

  Future<Either<Failure, CartModel>> removeItem({required int productId});

  Future<Either<Failure, CartModel>> clearCart();

  Future<Either<Failure, CartCheckoutResponseModel>> checkout();
}
