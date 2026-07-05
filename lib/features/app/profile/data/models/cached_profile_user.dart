import 'dart:convert';

import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/assets_data.dart';

class CachedProfileUser {
  final String name;
  final int points;
  final String image;

  const CachedProfileUser({
    required this.name,
    required this.points,
    required this.image,
  });

  factory CachedProfileUser.fromCache() {
    final cachedUser = CacheHelper.getData(key: 'user');
    if (cachedUser is! String || cachedUser.isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(cachedUser);
      if (decoded is! Map<String, dynamic>) {
        return fallback;
      }

      return CachedProfileUser(
        name: decoded['name']?.toString().isNotEmpty == true
            ? decoded['name'].toString()
            : fallback.name,
        points: _intFromJson(decoded['points']) ?? fallback.points,
        image: decoded['image']?.toString().isNotEmpty == true
            ? decoded['image'].toString()
            : fallback.image,
      );
    } catch (_) {
      return fallback;
    }
  }

  static const fallback = CachedProfileUser(
    name: '',
    points: 0,
    image: AssetsData.profile,
  );

  static int? _intFromJson(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
