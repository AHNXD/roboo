import '../../../../../core/utils/api_media_url_resolver.dart';
import 'store_category_model.dart';

class StoreProductModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String price;
  final bool isFavorite;
  final List<StoreProductMediaModel> mediaList;
  final StoreCategoryModel? category;

  const StoreProductModel({
    this.id,
    this.categoryId,
    this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.isFavorite,
    required this.mediaList,
    this.category,
  });

  factory StoreProductModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_list'];
    final categoryData = json['category'];

    return StoreProductModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      price: json['price']?.toString() ?? '',
      isFavorite: _parseBool(json['is_favorite']),
      mediaList: media is List
          ? media
                .whereType<Map<String, dynamic>>()
                .map(StoreProductMediaModel.fromJson)
                .toList()
          : const [],
      category: categoryData is Map<String, dynamic>
          ? StoreCategoryModel.fromJson(categoryData)
          : null,
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

  String get displayPrice => price.isEmpty ? '' : '\$$price';

  String get thumbnailUrl {
    if (mediaList.isEmpty) return '';
    final thumbnail = mediaList.where((media) {
      return media.collectionName == 'thumbnail' && media.imageUrl.isNotEmpty;
    }).firstOrNull;
    return thumbnail?.imageUrl ?? mediaList.first.imageUrl;
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

class StoreProductMediaModel {
  final int? id;
  final String collectionName;
  final String imageUrl;

  const StoreProductMediaModel({
    this.id,
    required this.collectionName,
    required this.imageUrl,
  });

  factory StoreProductMediaModel.fromJson(Map<String, dynamic> json) {
    return StoreProductMediaModel(
      id: StoreProductModel._parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image_url']?.toString()),
    );
  }
}
