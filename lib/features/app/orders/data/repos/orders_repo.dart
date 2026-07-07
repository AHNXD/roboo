import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/order_model.dart';

abstract class OrdersRepo {
  Future<Either<Failure, List<OrderModel>>> getOrderHistory();

  Future<Either<Failure, OrderModel>> getOrderDetails({required int orderId});
}
