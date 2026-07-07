import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;
  final CartSummaryModel summary;

  const CartModel({required this.items, required this.summary});

  const CartModel.empty()
    : items = const [],
      summary = const CartSummaryModel(itemCount: 0, subtotal: 0);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'];
    final summaryData = json['summary'];

    return CartModel(
      items: itemsData is List
          ? itemsData
                .whereType<Map<String, dynamic>>()
                .map(CartItemModel.fromJson)
                .toList()
          : const [],
      summary: summaryData is Map<String, dynamic>
          ? CartSummaryModel.fromJson(summaryData)
          : const CartSummaryModel(itemCount: 0, subtotal: 0),
    );
  }

  String get displaySubtotal => CartItemModel.formatPrice(subtotal);

  double get subtotal => summary.subtotal;
}

class CartSummaryModel {
  final int itemCount;
  final double subtotal;

  const CartSummaryModel({required this.itemCount, required this.subtotal});

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      itemCount: _parseInt(json['item_count']) ?? 0,
      subtotal: _parseDouble(json['subtotal']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
