import 'package:intl/intl.dart';

/// 后端时间字符串（"2024-05-01T12:00:00" / "2024-05-01 12:00:00"）兼容解析
DateTime? parseTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final text = raw.trim();
  return DateTime.tryParse(text) ?? DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

String formatDateTime(String? raw, {String pattern = 'yyyy-MM-dd HH:mm'}) {
  final time = parseTime(raw);
  if (time == null) return raw?.trim().isNotEmpty == true ? raw!.trim() : '-';
  return DateFormat(pattern).format(time.toLocal());
}

String formatRelative(String? raw) {
  final time = parseTime(raw);
  if (time == null) return '-';
  final now = DateTime.now();
  final diff = now.difference(time.toLocal());
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays < 7) return '${diff.inDays} 天前';
  return DateFormat('yyyy-MM-dd').format(time.toLocal());
}

String formatFileSize(num bytes) {
  if (bytes <= 0) return '0 B';
  if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
}
