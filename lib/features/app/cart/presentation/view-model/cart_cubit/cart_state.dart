part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  final CartModel cart;

  const CartState({required this.cart});

  List<CartItemModel> get items => cart.items;

  String get displayTotalPrice => cart.displaySubtotal;

  @override
  List<Object?> get props => [cart];
}

final class CartInitial extends CartState {
  const CartInitial() : super(cart: const CartModel.empty());
}

final class CartLoading extends CartState {
  const CartLoading({required super.cart});
}

final class CartLoaded extends CartState {
  const CartLoaded({required super.cart});
}

final class CartEmpty extends CartState {
  const CartEmpty({required super.cart});
}

final class CartLoadError extends CartState {
  final String errorMsg;

  const CartLoadError({required super.cart, required this.errorMsg});

  @override
  List<Object?> get props => [cart, errorMsg];
}

final class CartActionLoading extends CartState {
  final int productId;

  const CartActionLoading({required super.cart, required this.productId});

  @override
  List<Object?> get props => [cart, productId];
}

final class CartItemAdded extends CartState {
  final int productId;

  const CartItemAdded({required super.cart, required this.productId});

  @override
  List<Object?> get props => [cart, productId];
}

final class CartCheckoutLoading extends CartState {
  const CartCheckoutLoading({required super.cart});
}

final class CartCheckoutSuccess extends CartState {
  final CartCheckoutResponseModel response;

  const CartCheckoutSuccess({required this.response})
    : super(cart: const CartModel.empty());

  @override
  List<Object?> get props => [cart, response];
}

final class CartCheckoutError extends CartState {
  final String errorMsg;

  const CartCheckoutError({required super.cart, required this.errorMsg});

  @override
  List<Object?> get props => [cart, errorMsg];
}

final class CartActionError extends CartState {
  final String errorMsg;

  const CartActionError({required super.cart, required this.errorMsg});

  @override
  List<Object?> get props => [cart, errorMsg];
}
