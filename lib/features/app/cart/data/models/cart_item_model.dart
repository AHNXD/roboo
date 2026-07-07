import '../../../../../core/utils/api_media_url_resolver.dart';

class CartItemModel {
  final int? id;
  final int productId;
  final String title;
  final String titleAr;
  final String price;
  final String imageUrl;
  final int quantity;
  final double? lineTotal;

  const CartItemModel({
    this.id,
    required this.productId,
    required this.title,
    this.titleAr = '',
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    final product = productData is Map<String, dynamic> ? productData : null;

    return CartItemModel(
      id: _parseInt(json['id']),
      productId:
          _parseInt(json['product_id']) ?? _parseInt(product?['id']) ?? 0,
      title: _productName(product),
      titleAr: product?['name_ar']?.toString() ?? '',
      price: product?['price']?.toString() ?? '',
      imageUrl: _productImage(product),
      quantity: _parseInt(json['quantity']) ?? 0,
      lineTotal: _parseDouble(json['line_total']),
    );
  }

  CartItemModel copyWith({
    int? id,
    String? title,
    String? titleAr,
    String? price,
    String? imageUrl,
    int? quantity,
    double? lineTotal,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  double get unitPrice {
    final normalizedPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalizedPrice) ?? 0;
  }

  double get totalPrice => lineTotal ?? unitPrice * quantity;

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && titleAr.isNotEmpty) {
      return titleAr;
    }
    return title.isNotEmpty ? title : titleAr;
  }

  String get displayPrice => formatPrice(unitPrice);

  String get displayTotalPrice => formatPrice(totalPrice);

  static String formatPrice(double value) {
    final formattedValue = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '\$$formattedValue';
  }

  static String _productName(Map<String, dynamic>? product) {
    if (product == null) return '';
    return product['name']?.toString() ?? product['name_ar']?.toString() ?? '';
  }

  static String _productImage(Map<String, dynamic>? product) {
    final media = product?['media_list'];
    if (media is! List || media.isEmpty) return '';

    final mediaList = media.whereType<Map<String, dynamic>>().toList();
    final thumbnail = mediaList.where((item) {
      return item['collection_name']?.toString() == 'thumbnail' &&
          item['image_url']?.toString().isNotEmpty == true;
    }).firstOrNull;
    final imageUrl =
        thumbnail?['image_url']?.toString() ??
        mediaList.first['image_url']?.toString();

    return ApiMediaUrlResolver.resolve(imageUrl);
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
