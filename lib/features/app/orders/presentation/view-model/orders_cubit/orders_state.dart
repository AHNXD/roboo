part of 'orders_cubit.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersHistoryLoading extends OrdersState {
  const OrdersHistoryLoading();
}

final class OrdersHistoryLoaded extends OrdersState {
  final List<OrderModel> orders;

  const OrdersHistoryLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

final class OrdersHistoryEmpty extends OrdersState {
  const OrdersHistoryEmpty();
}

final class OrdersHistoryError extends OrdersState {
  final String errorMsg;

  const OrdersHistoryError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}

final class OrderDetailsLoading extends OrdersState {
  const OrderDetailsLoading();
}

final class OrderDetailsLoaded extends OrdersState {
  final OrderModel order;

  const OrderDetailsLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

final class OrderDetailsError extends OrdersState {
  final String errorMsg;

  const OrderDetailsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
