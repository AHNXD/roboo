import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/orders/presentation/view-model/orders_cubit/orders_cubit.dart';
import 'package:roboo/features/app/orders/presentation/view/order_details_screen.dart';
import 'package:roboo/features/app/orders/presentation/view/widgets/order_history_card_widget.dart';

class OrderHistoryScreen extends StatelessWidget {
  static const String routeName = "/order-history";

  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<OrdersCubit>()..getOrderHistory(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(title: "order_history_title".tr(context)),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            return switch (state) {
              OrdersInitial() || OrdersHistoryLoading() => StatusDisplayWidget(
                message: "wait".tr(context),
                withAnimation: true,
              ),
              OrdersHistoryError(:final errorMsg) => StatusDisplayWidget(
                message: errorMsg.tr(context),
              ),
              OrdersHistoryEmpty() => StatusDisplayWidget(
                message: "no_orders_found".tr(context),
              ),
              OrdersHistoryLoaded(:final orders) => RefreshIndicator(
                onRefresh: context.read<OrdersCubit>().getOrderHistory,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderHistoryCard(
                      order: order,
                      onTap: () {
                        final orderId = order.id;
                        if (orderId == null) return;

                        Navigator.pushNamed(
                          context,
                          OrderDetailsScreen.routeName,
                          arguments: OrderDetailsArgs(orderId: orderId),
                        );
                      },
                    );
                  },
                ),
              ),
              OrderDetailsLoading() ||
              OrderDetailsLoaded() ||
              OrderDetailsError() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
