import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/storage/image_cache_manager.dart';
import '../../core/util/urls.dart';

/// 用户头像：优先加载服务端返回的 photo，加载失败/为空时退回姓名首字
///
/// 之前各页面都只画了 CircleAvatar + 首字，服务端已经返回的 photo 字段
/// 完全没有用到，所以看起来「头像不显示」。
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.photo = '',
    this.apiBaseUrl = '',
    this.radius = 20,
  });

  final String name;
  final String photo;
  final String apiBaseUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = userAvatarUrl(photo, apiBaseUrl: apiBaseUrl);
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1) : '?';
    final scheme = Theme.of(context).colorScheme;
    final fallback = Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: radius, color: scheme.onPrimaryContainer),
      ),
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                cacheManager: ZyImageCacheManager.instance,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
