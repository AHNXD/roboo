class CartCheckoutResponseModel {
  final int? id;
  final String totalPrice;
  final String message;

  const CartCheckoutResponseModel({
    this.id,
    required this.totalPrice,
    required this.message,
  });

  factory CartCheckoutResponseModel.fromJson({
    required Map<String, dynamic> json,
    required String message,
  }) {
    return CartCheckoutResponseModel(
      id: _parseInt(json['id']),
      totalPrice: json['total_price']?.toString() ?? '',
      message: message,
    );
  }

  String get displayTotalPrice {
    final normalizedValue = totalPrice.trim();
    if (normalizedValue.isEmpty) return '';
    return normalizedValue.startsWith(r'$')
        ? normalizedValue
        : '\$$normalizedValue';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
