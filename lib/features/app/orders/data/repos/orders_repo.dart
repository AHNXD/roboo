import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/order_model.dart';

abstract class OrdersRepo {
  Future<Either<Failure, PagedResult<OrderModel>>> getOrderHistory({
    int page = 1,
  });

  Future<Either<Failure, OrderModel>> getOrderDetails({required int orderId});
}
