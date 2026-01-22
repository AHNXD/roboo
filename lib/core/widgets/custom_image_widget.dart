import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String placeholderAsset;
  final double? height;
  final double? width;
  final BoxFit fit;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    required this.placeholderAsset,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: height, width: width, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        placeholderAsset,
        height: height,
        width: width,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      width: width,
      fit: fit,

      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) =>
          Image.asset(placeholderAsset, height: height, width: width, fit: fit),
    );
  }
}
