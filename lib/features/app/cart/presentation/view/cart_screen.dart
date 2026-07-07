import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/features/app/cart/presentation/view-model/cart_cubit/cart_cubit.dart';
import 'package:roboo/features/app/cart/presentation/view/widgets/cart_bottom_bar_widget.dart';
import 'package:roboo/features/app/cart/presentation/view/widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = "/cart";
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getit<CartCubit>()..loadCart(),
      child: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartCheckoutSuccess) {
            messages(
              context,
              "cart_checkout_success".tr(context),
              AppColors.green,
            );
          } else if (state is CartCheckoutError) {
            messages(context, state.errorMsg.tr(context), AppColors.red);
          } else if (state is CartActionError) {
            messages(context, state.errorMsg.tr(context), AppColors.red);
          }
        },
        builder: (context, state) {
          final isInitialLoading = state is CartLoading && state.items.isEmpty;
          final isCheckoutLoading = state is CartCheckoutLoading;

          return Scaffold(
            bottomNavigationBar: CartBottomBar(
              totalPrice: state.displayTotalPrice,
              isLoading: isCheckoutLoading,
              onConfirm: isCheckoutLoading
                  ? () {}
                  : context.read<CartCubit>().checkout,
            ),
            backgroundColor: Colors.white,
            appBar: CustomAppbar(
              title: "cart_title".tr(context),
              showBackButton: true,
            ),
            body: _buildBody(context, state, isInitialLoading),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartState state,
    bool isInitialLoading,
  ) {
    if (isInitialLoading) {
      return StatusDisplayWidget(
        message: "wait".tr(context),
        withAnimation: true,
      );
    }

    if (state is CartLoadError && state.items.isEmpty) {
      return StatusDisplayWidget(message: state.errorMsg.tr(context));
    }

    if (state.items.isEmpty) {
      return StatusDisplayWidget(message: "empty_cart_text".tr(context));
    }

    return RefreshIndicator(
      onRefresh: context.read<CartCubit>().loadCart,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: state.items.length,
        separatorBuilder: (c, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = state.items[index];
          final isItemLoading =
              state is CartActionLoading && state.productId == item.productId;

          return CartItemWidget(
            item: item,
            isLoading: isItemLoading,
            onRemove: () {
              context.read<CartCubit>().removeProduct(item.productId);
            },
            onIncrease: () {
              context.read<CartCubit>().increaseQuantity(item.productId);
            },
            onDecrease: () {
              context.read<CartCubit>().decreaseQuantity(item.productId);
            },
          );
        },
      ),
    );
  }
}
