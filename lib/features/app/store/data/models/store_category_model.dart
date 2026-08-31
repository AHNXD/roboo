import 'package:flutter/material.dart';

import '../../../../../core/utils/api_media_url_resolver.dart';
import '../../../../../core/utils/hex_color.dart';

class StoreCategoryModel {
  final int? id;
  final String? name;
  final String? nameAr;

  /// The category's icon. Empty when none has been uploaded.
  final String imageUrl;

  /// The dashboard's colour for this category, as a hex string.
  final String? color;

  final String? createdAt;
  final String? updatedAt;

  const StoreCategoryModel({
    this.id,
    this.name,
    this.nameAr,
    this.createdAt,
    this.updatedAt,
    this.imageUrl = '',
    this.color,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    return StoreCategoryModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      imageUrl: ApiMediaUrlResolver.resolve(json['image']?.toString()),
      color: json['color']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get hasImage => imageUrl.isNotEmpty;

  Color? get displayColor => colorFromHex(color);

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && nameAr?.isNotEmpty == true) {
      return nameAr!;
    }
    return name?.isNotEmpty == true ? name! : nameAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
