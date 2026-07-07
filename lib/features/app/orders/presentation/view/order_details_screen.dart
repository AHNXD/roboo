import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/orders/data/models/order_model.dart';
import 'package:roboo/features/app/orders/presentation/view-model/orders_cubit/orders_cubit.dart';
import 'package:roboo/features/app/orders/presentation/view/widgets/order_item_card_widget.dart';

class OrderDetailsArgs {
  final int orderId;

  const OrderDetailsArgs({required this.orderId});

  static int? orderIdFrom(Object? args) {
    if (args is OrderDetailsArgs) return args.orderId;
    if (args is int) return args;
    if (args is Map && args['orderId'] is int) {
      return args['orderId'] as int;
    }
    return null;
  }
}

class OrderDetailsScreen extends StatelessWidget {
  static const String routeName = "/order-details";

  final int? orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  factory OrderDetailsScreen.fromRouteArgs(Object? args) {
    return OrderDetailsScreen(orderId: OrderDetailsArgs.orderIdFrom(args));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<OrdersCubit>()..getOrderDetails(orderId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(title: "order_details_title".tr(context)),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            return switch (state) {
              OrdersInitial() || OrderDetailsLoading() => StatusDisplayWidget(
                message: "wait".tr(context),
                withAnimation: true,
              ),
              OrderDetailsError(:final errorMsg) => StatusDisplayWidget(
                message: errorMsg.tr(context),
              ),
              OrderDetailsLoaded(:final order) => _OrderDetailsContent(
                order: order,
              ),
              OrdersHistoryLoading() ||
              OrdersHistoryLoaded() ||
              OrdersHistoryEmpty() ||
              OrdersHistoryError() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final orderDate = order.displayDate;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: "order_number".tr(context),
                value: order.id?.toString() ?? '',
              ),
              if (orderDate.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(label: "order_date".tr(context), value: orderDate),
              ],
              const SizedBox(height: 10),
              _InfoRow(
                label: "order_total".tr(context),
                value: order.displayTotalPrice,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "order_items".tr(context),
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (order.items.isEmpty)
          StatusDisplayWidget(message: "no_order_items_found".tr(context))
        else
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OrderItemCard(item: item, languageCode: languageCode),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColors,
            ),
          ),
        ),
      ],
    );
  }
}
