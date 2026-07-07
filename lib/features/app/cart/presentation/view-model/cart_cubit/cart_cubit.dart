import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cart_model.dart';
import '../../../data/models/cart_checkout_response_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repos/cart_repo.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo _cartRepo;
  CartModel _cart = const CartModel.empty();

  CartCubit(this._cartRepo) : super(const CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading(cart: _cart));

    final result = await _cartRepo.getCart();
    result.fold(
      (failure) => emit(CartLoadError(cart: _cart, errorMsg: failure.message)),
      (cart) => _emitCart(cart),
    );
  }

  Future<void> addProduct({required int? productId, int quantity = 1}) {
    if (productId == null) {
      emit(CartActionError(cart: _cart, errorMsg: 'cart_product_unavailable'));
      return Future.value();
    }

    if (quantity < 1) {
      emit(CartActionError(cart: _cart, errorMsg: 'enter_valid_number'));
      return Future.value();
    }

    return _addProduct(productId: productId, quantity: quantity);
  }

  Future<void> _addProduct({
    required int productId,
    required int quantity,
  }) async {
    emit(CartActionLoading(cart: _cart, productId: productId));

    final result = await _cartRepo.addItem(
      productId: productId,
      quantity: quantity,
    );
    result.fold(
      (failure) =>
          emit(CartActionError(cart: _cart, errorMsg: failure.message)),
      (cart) {
        _cart = cart;
        emit(CartItemAdded(cart: cart, productId: productId));
      },
    );
  }

  Future<void> increaseQuantity(int productId) async {
    final item = _cart.items
        .where((item) => item.productId == productId)
        .firstOrNull;
    if (item == null) return;

    await updateQuantity(productId: productId, quantity: item.quantity + 1);
  }

  Future<void> decreaseQuantity(int productId) async {
    final item = _cart.items
        .where((item) => item.productId == productId)
        .firstOrNull;
    if (item == null || item.quantity <= 1) return;

    await updateQuantity(productId: productId, quantity: item.quantity - 1);
  }

  Future<void> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    if (quantity < 1) return;

    emit(CartActionLoading(cart: _cart, productId: productId));

    final result = await _cartRepo.updateItem(
      productId: productId,
      quantity: quantity,
    );
    result.fold(
      (failure) =>
          emit(CartActionError(cart: _cart, errorMsg: failure.message)),
      _emitCart,
    );
  }

  Future<void> removeProduct(int productId) async {
    emit(CartActionLoading(cart: _cart, productId: productId));

    final result = await _cartRepo.removeItem(productId: productId);
    result.fold(
      (failure) =>
          emit(CartActionError(cart: _cart, errorMsg: failure.message)),
      _emitCart,
    );
  }

  Future<void> clearCart() async {
    emit(CartLoading(cart: _cart));

    final result = await _cartRepo.clearCart();
    result.fold(
      (failure) =>
          emit(CartActionError(cart: _cart, errorMsg: failure.message)),
      _emitCart,
    );
  }

  Future<void> checkout() async {
    if (_cart.items.isEmpty) {
      emit(CartActionError(cart: _cart, errorMsg: 'empty_cart_text'));
      return;
    }

    emit(CartCheckoutLoading(cart: _cart));

    final result = await _cartRepo.checkout();
    result.fold(
      (failure) =>
          emit(CartCheckoutError(cart: _cart, errorMsg: failure.message)),
      (response) {
        _cart = const CartModel.empty();
        emit(CartCheckoutSuccess(response: response));
      },
    );
  }

  void _emitCart(CartModel cart) {
    _cart = cart;
    if (cart.items.isEmpty) {
      emit(CartEmpty(cart: cart));
      return;
    }

    emit(CartLoaded(cart: cart));
  }
}
