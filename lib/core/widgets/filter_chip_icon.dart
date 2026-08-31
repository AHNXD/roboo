import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// The little icon on a filter chip.
///
/// Topics and product categories now carry an uploaded icon, but not every one
/// of them has had a picture set yet — and the chips also use bundled assets in
/// places. This takes either: an http url is fetched and cached, anything else
/// is treated as an asset path. A missing or broken icon renders nothing at
/// all, so the chip falls back to being text-only rather than showing a broken
/// image box.
class FilterChipIcon extends StatelessWidget {
  final String? source;
  final double size;
  final Color? tint;

  const FilterChipIcon({
    super.key,
    required this.source,
    this.size = 24,
    this.tint,
  });

  bool get _isNetwork => source?.startsWith('http') == true;

  @override
  Widget build(BuildContext context) {
    final path = source?.trim();
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // No spinner: a chip is small enough that a flash of empty space reads
        // better than a loading indicator inside it.
        placeholder: (_, _) => SizedBox(width: size, height: size),
        errorWidget: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      color: tint,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
