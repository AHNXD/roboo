import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';

class SkewedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  /// Fills the shape with a picture instead of the icon — a lesson's own video
  /// frame, the way a course card shows its cover. The icon stays as the
  /// fallback for lessons with no video, and while the image loads.
  final String? imageUrl;

  const SkewedIcon({
    super.key,
    this.icon = Icons.play_arrow_rounded,
    this.color = AppColors.primaryTwoColors,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    const double skewAmount = -0.25;

    return Transform(
      transform: Matrix4.skewX(isRtl ? skewAmount : -skewAmount),
      alignment: Alignment.center,
      child: Container(
        width: 65,
        height: 65,
        // Clips the picture to the slanted rounded shape, so the image is the
        // shape rather than a straight rectangle sitting inside it.
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: _buildContent(isRtl, skewAmount),
      ),
    );
  }

  Widget _buildContent(bool isRtl, double skewAmount) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) return _buildIcon(isRtl, skewAmount);

    // No counter-skew here: the picture is meant to lean with the shape, the
    // way the cover does on a course card.
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: 65,
      height: 65,
      placeholder: (_, _) => _buildIcon(isRtl, skewAmount),
      errorWidget: (_, _, _) => _buildIcon(isRtl, skewAmount),
    );
  }

  /// The glyph is counter-skewed so it stays upright inside the slanted shape.
  Widget _buildIcon(bool isRtl, double skewAmount) {
    return Transform(
      transform: Matrix4.skewX(isRtl ? -skewAmount : skewAmount),
      alignment: Alignment.center,
      child: Center(child: Icon(icon, color: Colors.white, size: 32)),
    );
  }
}
