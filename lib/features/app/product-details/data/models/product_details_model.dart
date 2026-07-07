import '../../../../../core/utils/api_media_url_resolver.dart';

class ProductDetailsModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String price;
  final bool isFavorite;
  final List<ProductDetailsSpecificationModel> specifications;
  final List<ProductDetailsSpecificationModel> specificationsAr;
  final List<ProductDetailsMediaModel> mediaList;

  const ProductDetailsModel({
    this.id,
    this.categoryId,
    this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.isFavorite,
    required this.specifications,
    required this.specificationsAr,
    required this.mediaList,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_list'];

    return ProductDetailsModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      price: json['price']?.toString() ?? '',
      isFavorite: _parseBool(json['is_favorite']),
      specifications: ProductDetailsSpecificationModel.parseList(
        json['specifications'],
      ),
      specificationsAr: ProductDetailsSpecificationModel.parseList(
        json['specifications_ar'],
      ),
      mediaList: media is List
          ? media
                .whereType<Map<String, dynamic>>()
                .map(ProductDetailsMediaModel.fromJson)
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

  String descriptionFor(String languageCode) {
    if (languageCode == 'ar' && descriptionAr?.isNotEmpty == true) {
      return descriptionAr!;
    }
    return description?.isNotEmpty == true ? description! : descriptionAr ?? '';
  }

  List<ProductDetailsSpecificationModel> specificationsFor(
    String languageCode,
  ) {
    if (languageCode == 'ar' && specificationsAr.isNotEmpty) {
      return specificationsAr;
    }
    return specifications.isNotEmpty ? specifications : specificationsAr;
  }

  String get displayPrice => price.isEmpty ? '' : '\$$price';

  String get primaryImageUrl {
    if (mediaList.isEmpty) return '';
    final thumbnail = mediaList.where((media) {
      return media.collectionName == 'thumbnail' && media.imageUrl.isNotEmpty;
    }).firstOrNull;
    return thumbnail?.imageUrl ?? mediaList.first.imageUrl;
  }

  List<String> get imageUrls {
    if (mediaList.isEmpty) return const [];

    final thumbnail = mediaList.where((media) {
      return media.collectionName == 'thumbnail' && media.imageUrl.isNotEmpty;
    }).firstOrNull;
    final orderedMedia = [
      if (thumbnail != null) thumbnail,
      ...mediaList.where((media) => media != thumbnail),
    ];

    return orderedMedia
        .map((media) => media.imageUrl)
        .where((imageUrl) => imageUrl.isNotEmpty)
        .toList();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalizedValue = value?.toString().toLowerCase();
    return normalizedValue == 'true' || normalizedValue == '1';
  }
}

class ProductDetailsSpecificationModel {
  final String key;
  final String value;

  const ProductDetailsSpecificationModel({
    required this.key,
    required this.value,
  });

  String get displayText {
    if (key.isEmpty) return value;
    if (value.isEmpty) return key;
    return '$key: $value';
  }

  static List<ProductDetailsSpecificationModel> parseList(dynamic data) {
    if (data is Map) {
      return data.entries
          .map(
            (entry) => ProductDetailsSpecificationModel(
              key: entry.key.toString(),
              value: entry.value?.toString() ?? '',
            ),
          )
          .toList();
    }

    if (data is List) {
      return data.map((item) {
        if (item is Map) {
          return ProductDetailsSpecificationModel(
            key: item['key']?.toString() ?? '',
            value: item['value']?.toString() ?? '',
          );
        }

        return ProductDetailsSpecificationModel(
          key: '',
          value: item.toString(),
        );
      }).toList();
    }

    return const [];
  }
}

class ProductDetailsMediaModel {
  final int? id;
  final String collectionName;
  final String imageUrl;

  const ProductDetailsMediaModel({
    this.id,
    required this.collectionName,
    required this.imageUrl,
  });

  factory ProductDetailsMediaModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsMediaModel(
      id: ProductDetailsModel._parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image_url']?.toString()),
    );
  }
}
