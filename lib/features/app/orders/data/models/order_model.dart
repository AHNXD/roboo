import '../../../../../core/utils/api_media_url_resolver.dart';

class OrderModel {
  final int? id;
  final int? userId;
  final String totalPrice;
  final String? createdAt;
  final String? updatedAt;
  final List<OrderItemModel> items;
  final OrderUserModel? user;

  const OrderModel({
    this.id,
    this.userId,
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
    required this.items,
    this.user,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'];
    final userData = json['user'];

    return OrderModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      totalPrice: json['total_price']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      items: itemsData is List
          ? itemsData
                .whereType<Map<String, dynamic>>()
                .map(OrderItemModel.fromJson)
                .toList()
          : const [],
      user: userData is Map<String, dynamic>
          ? OrderUserModel.fromJson(userData)
          : null,
    );
  }

  String get displayTotalPrice => _formatPrice(totalPrice);

  String get displayDate {
    final date = DateTime.tryParse(createdAt ?? '');
    if (date == null) return '';

    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '${localDate.year}/$month/$day';
  }

  static String _formatPrice(String value) {
    final normalizedValue = value.trim();
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

class OrderItemModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final int quantity;
  final String unitPrice;
  final OrderProductModel? product;

  const OrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    required this.quantity,
    required this.unitPrice,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];

    return OrderItemModel(
      id: OrderModel._parseInt(json['id']),
      orderId: OrderModel._parseInt(json['order_id']),
      productId: OrderModel._parseInt(json['product_id']),
      quantity: OrderModel._parseInt(json['quantity']) ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '',
      product: productData is Map<String, dynamic>
          ? OrderProductModel.fromJson(productData)
          : null,
    );
  }

  String get displayUnitPrice => OrderModel._formatPrice(unitPrice);

  String get displayLineTotal {
    final normalizedPrice = unitPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(normalizedPrice);
    if (price == null) return displayUnitPrice;

    final total = price * quantity;
    final formatted = total % 1 == 0
        ? total.toInt().toString()
        : total.toStringAsFixed(2);
    return '\$$formatted';
  }
}

class OrderProductModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String price;
  final List<OrderProductMediaModel> mediaList;

  const OrderProductModel({
    this.id,
    this.categoryId,
    this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.mediaList,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_list'];

    return OrderProductModel(
      id: OrderModel._parseInt(json['id']),
      categoryId: OrderModel._parseInt(json['category_id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      price: json['price']?.toString() ?? '',
      mediaList: media is List
          ? media
                .whereType<Map<String, dynamic>>()
                .map(OrderProductMediaModel.fromJson)
                .toList()
          : const [],
    );
  }

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && nameAr?.isNotEmpty == true) {
      return nameAr!;
    }
    return name?.isNotEmpty == true ? name! : nameAr ?? '';
  }

  String get thumbnailUrl {
    if (mediaList.isEmpty) return '';
    final thumbnail = mediaList.where((media) {
      return media.collectionName == 'thumbnail' && media.imageUrl.isNotEmpty;
    }).firstOrNull;
    return thumbnail?.imageUrl ?? mediaList.first.imageUrl;
  }
}

class OrderProductMediaModel {
  final int? id;
  final String collectionName;
  final String imageUrl;

  const OrderProductMediaModel({
    this.id,
    required this.collectionName,
    required this.imageUrl,
  });

  factory OrderProductMediaModel.fromJson(Map<String, dynamic> json) {
    return OrderProductMediaModel(
      id: OrderModel._parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image_url']?.toString()),
    );
  }
}

class OrderUserModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? email;
  final String? image;

  const OrderUserModel({
    this.id,
    this.name,
    this.nameAr,
    this.email,
    this.image,
  });

  factory OrderUserModel.fromJson(Map<String, dynamic> json) {
    return OrderUserModel(
      id: OrderModel._parseInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      email: json['email']?.toString(),
      image: ApiMediaUrlResolver.resolve(json['image']?.toString()),
    );
  }
}
