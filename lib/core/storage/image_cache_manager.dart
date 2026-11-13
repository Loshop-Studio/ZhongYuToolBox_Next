import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 图库、随身答和领创图标共用的独立图片文件缓存。
class ZyImageCacheManager {
  ZyImageCacheManager._();

  static final CacheManager instance = CacheManager(
    Config(
      'zytb_image_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 1000,
    ),
  );

  static Future<void> clear() async {
    await instance.emptyCache();
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
