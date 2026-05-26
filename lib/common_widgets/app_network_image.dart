import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget;
  final Widget? placeholder;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || imageUrl.toLowerCase() == "null") {
      return _buildError();
    }

    final imageWidth = width;
    final imageHeight = height;
    final memCacheWidth = imageWidth != null && imageWidth.isFinite ? (imageWidth * 2).toInt() : null;
    final memCacheHeight = imageHeight != null && imageHeight.isFinite ? (imageHeight * 2).toInt() : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: imageWidth,
        height: imageHeight,
        fit: fit,
        // Optimize memory usage by resizing at decode time only when dimensions are finite
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) => placeholder ?? Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: imageWidth ?? double.infinity,
            height: imageHeight ?? double.infinity,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => errorWidget ?? _buildError(),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
    );
  }
}