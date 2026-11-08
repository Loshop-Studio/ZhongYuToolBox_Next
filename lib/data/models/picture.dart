class PictureItem {
  PictureItem({
    required this.id,
    required this.picture,
    required this.name,
    required this.size,
    required this.createTime,
    required this.raw,
  });

  final String id;
  final String picture;
  final String name;
  final String size;
  final String createTime;
  final Map<String, dynamic> raw;

  /// 服务端返回的 size 可能是字节数或已格式化字符串
  String get sizeText {
    final bytes = int.tryParse(size);
    if (bytes == null) return size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  factory PictureItem.fromJson(Map<String, dynamic> json) {
    return PictureItem(
      id: (json['id'] ?? '').toString(),
      picture: (json['picture'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      createTime: (json['createTime'] ?? '').toString(),
      raw: json,
    );
  }
}
