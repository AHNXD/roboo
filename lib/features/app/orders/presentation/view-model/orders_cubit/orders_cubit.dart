import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repos/orders_repo.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepo _ordersRepo;

  OrdersCubit(this._ordersRepo) : super(const OrdersInitial());

  Future<void> getOrderHistory() async {
    emit(const OrdersHistoryLoading());

    final result = await _ordersRepo.getOrderHistory();
    result.fold(
      (failure) => emit(OrdersHistoryError(errorMsg: failure.message)),
      (orders) {
        if (orders.isEmpty) {
          emit(const OrdersHistoryEmpty());
          return;
        }

        emit(OrdersHistoryLoaded(orders: orders));
      },
    );
  }

  Future<void> getOrderDetails(int? orderId) async {
    if (orderId == null) {
      emit(const OrderDetailsError(errorMsg: 'order_unavailable'));
      return;
    }

    emit(const OrderDetailsLoading());

    final result = await _ordersRepo.getOrderDetails(orderId: orderId);
    result.fold(
      (failure) => emit(OrderDetailsError(errorMsg: failure.message)),
      (order) => emit(OrderDetailsLoaded(order: order)),
    );
  }
}
