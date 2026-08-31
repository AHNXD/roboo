import 'package:flutter/material.dart';

import '../../../../../core/utils/api_media_url_resolver.dart';
import '../../../../../core/utils/hex_color.dart';

class TopicModel {
  final int? id;
  final String? name;
  final String? nameAr;

  /// The topic's icon. Empty when the dashboard has not uploaded one, which is
  /// the case for several topics today — callers fall back to their own asset.
  final String imageUrl;

  /// The dashboard's colour for this topic, as a hex string. Null for most
  /// topics today, and callers keep their own default when it is.
  final String? color;

  /// Stable identifier for a topic, unlike the id, which differs between
  /// environments. The home screen's three fixed shapes address topics by this.
  final String? slug;

  const TopicModel({
    this.id,
    this.name,
    this.nameAr,
    this.imageUrl = '',
    this.color,
    this.slug,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      imageUrl: ApiMediaUrlResolver.resolve(json['image']?.toString()),
      color: json['color']?.toString(),
      slug: json['slug']?.toString(),
    );
  }

  bool get hasImage => imageUrl.isNotEmpty;

  /// Null when unset or unparseable, so the widget keeps its existing colour.
  Color? get displayColor => colorFromHex(color);

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && nameAr?.isNotEmpty == true) {
      return nameAr!;
    }

    return name?.isNotEmpty == true ? name! : nameAr ?? '';
  }
}
