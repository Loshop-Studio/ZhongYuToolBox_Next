class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// 统一把异常转成可展示文案
String errorText(Object? error) {
  if (error == null) return '未知错误';
  if (error is ApiException) return error.message;
  final text = error.toString();
  if (text.startsWith('Exception: ')) return text.substring(11);
  return text;
}
