import 'dart:math';

import 'cache_helper.dart';

/// `POST courses/{id}/reserve-click` wants a stable `device_id` for marketing
/// follow-up. The project has no device-info package, so this generates one id
/// per install and keeps it in the same cache the token lives in.
class DeviceIdProvider {
  const DeviceIdProvider._();

  static const String _cacheKey = 'device_id';

  static Future<String> get() async {
    final cached = CacheHelper.getData(key: _cacheKey)?.toString();
    if (cached != null && cached.isNotEmpty) return cached;

    final deviceId = _generate();
    await CacheHelper.setString(key: _cacheKey, value: deviceId);
    return deviceId;
  }

  static String _generate() {
    final random = Random();
    final suffix = List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();

    return '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}-$suffix';
  }
}
