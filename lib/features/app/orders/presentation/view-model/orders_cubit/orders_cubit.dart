import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repos/orders_repo.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> with SafeEmit<OrdersState> {
  final OrdersRepo _ordersRepo;

  OrdersCubit(this._ordersRepo) : super(const OrdersInitial());

  List<OrderModel> _orders = const [];
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> getOrderHistory() async {
    emit(const OrdersHistoryLoading());

    final result = await _ordersRepo.getOrderHistory();
    result.fold(
      (failure) => safeEmit(OrdersHistoryError(errorMsg: failure.message)),
      (page) {
        _orders = page.items;
        _pagination = page.pagination;

        if (_orders.isEmpty) {
          safeEmit(const OrdersHistoryEmpty());
          return;
        }

        safeEmit(OrdersHistoryLoaded(orders: _orders, hasMore: page.hasMore));
      },
    );
  }

  /// Appends the next page of order history.
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(
      OrdersHistoryLoaded(orders: _orders, hasMore: true, isLoadingMore: true),
    );

    final result = await _ordersRepo.getOrderHistory(
      page: _pagination.nextPage,
    );

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(
        OrdersHistoryLoaded(orders: _orders, hasMore: _pagination.hasMore),
      ),
      (page) {
        _orders = [..._orders, ...page.items];
        _pagination = page.pagination;
        safeEmit(OrdersHistoryLoaded(orders: _orders, hasMore: page.hasMore));
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
