import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/cart/presentation/view/widgets/cart_bottom_bar_widget.dart';
import 'package:roboo/features/app/cart/presentation/view/widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = "/cart";
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      "title": "كود مصدري لنظام سياحي",
      "price": 2500,
      "image": AssetsData.sourceCode,
    },
    {"title": "عدة ليغو", "price": 100, "image": AssetsData.legoKit},
    {"title": "روبو الحبوب", "price": 275, "image": AssetsData.robot},
  ];

  int get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + (item['price'] as int));

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartBottomBar(
        totalPrice: _totalPrice,
        onConfirm: () {},
      ),
      backgroundColor: Colors.white,
      appBar: CustomAppbar(
        title: "cart_title".tr(context),
        showBackButton: true,
      ),
      body: _cartItems.isEmpty
          ? StatusDisplayWidget(message: "empty_cart_text".tr(context))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _cartItems.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return CartItemWidget(
                  item: _cartItems[index],
                  onRemove: () => _removeItem(index),
                );
              },
            ),
    );
  }
}
