import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/order_model.dart';
import 'orders_repo.dart';

class OrdersRepoImpl implements OrdersRepo {
  final ApiServices _apiServices;

  static const String _ordersEndpoint = 'orders';

  OrdersRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<OrderModel>>> getOrderHistory() async {
    try {
      final resp = await _apiServices.get(endPoint: _ordersEndpoint);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final paginationData = responseData['data'];
        final data = paginationData is Map<String, dynamic>
            ? paginationData['data']
            : null;

        if (data is List) {
          final orders = data
              .whereType<Map<String, dynamic>>()
              .map(OrderModel.fromJson)
              .toList();
          return right(orders);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderDetails({
    required int orderId,
  }) async {
    try {
      final resp = await _apiServices.get(
        endPoint: '$_ordersEndpoint/$orderId',
      );
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(OrderModel.fromJson(data));
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
