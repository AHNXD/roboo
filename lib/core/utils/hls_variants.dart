import 'package:dio/dio.dart';

/// One rendition listed in an HLS master playlist.
class HlsVariant {
  /// e.g. 720 for a 1280x720 stream.
  final int height;
  final int bandwidth;

  /// Absolute, already-signed url for this rendition.
  final String url;

  const HlsVariant({
    required this.height,
    required this.bandwidth,
    required this.url,
  });

  String get label => '${height}p';
}

/// Reads the renditions out of an HLS master playlist so the student can pick
/// one, instead of the player silently choosing for them.
///
/// The backend rewrites every line of its playlists into absolute signed urls,
/// so a variant line can be used as-is; a relative line is still resolved
/// against the master's own url rather than dropped.
class HlsVariantReader {
  final Dio _dio;

  HlsVariantReader({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<HlsVariant>> variantsOf(String masterUrl) async {
    try {
      final response = await _dio.get<String>(
        masterUrl,
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data;
      if (body == null || !body.contains('#EXT-X-STREAM-INF')) {
        // A media playlist rather than a master: one rendition, nothing to pick.
        return const [];
      }

      return parse(body, masterUrl);
    } catch (_) {
      // Quality selection is a convenience; failing to read the playlist must
      // never stop the video from playing.
      return const [];
    }
  }

  /// Split out from the fetch so it can be exercised without a network call.
  static List<HlsVariant> parse(String playlist, String masterUrl) {
    final variants = <HlsVariant>[];
    final lines = playlist.split(RegExp(r'\r?\n'));

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXT-X-STREAM-INF')) continue;

      // The url is the next non-comment, non-empty line.
      String? target;
      for (var j = i + 1; j < lines.length; j++) {
        final candidate = lines[j].trim();
        if (candidate.isEmpty || candidate.startsWith('#')) continue;
        target = candidate;
        break;
      }
      if (target == null) continue;

      final height = int.tryParse(
        RegExp(r'RESOLUTION=\d+x(\d+)').firstMatch(line)?.group(1) ?? '',
      );
      if (height == null) continue;

      variants.add(
        HlsVariant(
          height: height,
          bandwidth:
              int.tryParse(
                RegExp(r'BANDWIDTH=(\d+)').firstMatch(line)?.group(1) ?? '',
              ) ??
              0,
          url: _absolute(target, masterUrl),
        ),
      );
    }

    // Highest first, and never two entries for the same resolution.
    variants.sort((a, b) => b.height.compareTo(a.height));

    final seen = <int>{};
    return variants.where((variant) => seen.add(variant.height)).toList();
  }

  static String _absolute(String target, String masterUrl) {
    if (target.startsWith('http')) return target;

    final base = Uri.tryParse(masterUrl);
    if (base == null) return target;

    return base.resolve(target).toString();
  }
}
