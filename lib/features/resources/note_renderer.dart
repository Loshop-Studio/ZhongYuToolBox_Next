import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/note.dart';

/// 一页笔记的展示数据
class NotePageData {
  NotePageData({
    required this.pageNumber,
    required this.screenshotUrl,
    required this.originals,
    this.hasBoardData = false,
  });

  final int pageNumber;

  /// resourceType = 2 的整页截图
  final String? screenshotUrl;

  /// resourceType = 0 / 其它 的页内图片
  final List<String> originals;

  /// 是否存在 snapshot.bin / data.mdb 等矢量画板数据
  final bool hasBoardData;

  bool get isEmpty => screenshotUrl == null && originals.isEmpty;
}

/// 笔记页渲染器抽象。
///
/// 当前只提供截图渲染（ScreenshotNoteRenderer）。后续若要支持
/// snapshot.bin + data.mdb 的矢量画板，新增一个实现即可，页面无需改动。
abstract class NoteBoardRenderer {
  const NoteBoardRenderer();

  Widget buildPage(BuildContext context, NotePageData page);

  String get name;
}

class ScreenshotNoteRenderer extends NoteBoardRenderer {
  const ScreenshotNoteRenderer();

  @override
  String get name => '截图渲染';

  @override
  Widget buildPage(BuildContext context, NotePageData page) {
    final url = page.screenshotUrl;
    if (url == null || url.isEmpty) {
      return const Center(
        child: Text(
          '该页没有可用截图',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, __, ___) => const Center(
            child: Text(
              '图片加载失败',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

/// 把接口返回的资源按页分组
List<NotePageData> groupNotePages(List<NoteResource> resources) {
  final screenshots = <int, String>{};
  final originals = <int, List<String>>{};
  final boardPages = <int>{};

  for (final item in resources) {
    final page = item.pageIndex + 1;
    if (item.resourceType == 1) {
      boardPages.add(page);
      continue;
    }
    final url = absoluteResourceUrl(item.ossImageUrl);
    if (url.isEmpty) continue;
    if (item.resourceType == 2) {
      screenshots[page] = url;
    } else {
      originals.putIfAbsent(page, () => <String>[]).add(url);
    }
  }

  final pageNumbers = <int>{...screenshots.keys, ...originals.keys}.toList()
    ..sort();
  return pageNumbers
      .map(
        (page) => NotePageData(
          pageNumber: page,
          screenshotUrl: screenshots[page],
          originals: originals[page] ?? const <String>[],
          hasBoardData: boardPages.contains(page),
        ),
      )
      .toList();
}

String absoluteResourceUrl(String ossImageUrl) {
  if (ossImageUrl.isEmpty) return '';
  if (ossImageUrl.startsWith('http://') || ossImageUrl.startsWith('https://')) {
    return ossImageUrl;
  }
  return 'http://friday-note.oss-cn-hangzhou.aliyuncs.com/$ossImageUrl';
}
