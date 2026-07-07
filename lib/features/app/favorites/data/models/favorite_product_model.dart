import '../../../../../core/utils/api_media_url_resolver.dart';

class FavoriteProductModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String price;
  final List<FavoriteProductMediaModel> mediaList;

  const FavoriteProductModel({
    this.id,
    this.categoryId,
    this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.mediaList,
  });

  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_list'];

    return FavoriteProductModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      price: json['price']?.toString() ?? '',
      mediaList: media is List
          ? media
                .whereType<Map<String, dynamic>>()
                .map(FavoriteProductMediaModel.fromJson)
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
}

class FavoriteProductMediaModel {
  final int? id;
  final String collectionName;
  final String imageUrl;

  const FavoriteProductMediaModel({
    this.id,
    required this.collectionName,
    required this.imageUrl,
  });

  factory FavoriteProductMediaModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductMediaModel(
      id: FavoriteProductModel._parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image_url']?.toString()),
    );
  }
}
