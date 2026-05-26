import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ziya_laundry_deliveryapp/core/Constants/app_images.dart';

class AdvancedCachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AdvancedCachedImage({super.key, required this.imageUrl, this.fit = BoxFit.cover, this.width, this.height, this.borderRadius});

  @override
  State<AdvancedCachedImage> createState() => _AdvancedCachedImageState();
}

class _AdvancedCachedImageState extends State<AdvancedCachedImage> {
  late String _key;
  static final BaseCacheManager _customCacheManager = CacheManager(
    Config(
      'premiumCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'premiumCache'),
      fileService: HttpFileService(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _key = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant AdvancedCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure the internal state updates when the image URL changes (e.g., after upload)
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _key = widget.imageUrl;
      });
    }
  }

  void _retry() {
    setState(() {
      _key = '${widget.imageUrl}?r=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return CachedNetworkImage(
        imageUrl: AppImages.defaultProfile,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );
    }
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        key: ValueKey(_key),
        cacheManager: _customCacheManager,
        imageUrl: _key,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade200,
        ),
        errorWidget: (context, url, error) => GestureDetector(
          onTap: _retry,
          child: Container(
            color: Colors.grey.shade200,
            width: widget.width,
            height: widget.height,
            child: Center(
              child: Icon(Icons.refresh, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}
