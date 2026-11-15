import 'dart:convert';
import 'dart:io';

/// 由宿主执行插件 HTTP 请求，绕过 dart_eval 不完整的 HttpClient 桥接。
abstract final class PluginHttpService {
  static Future<Map<String, dynamic>> request({
    required String method,
    required String url,
    Map<String, String> headers = const <String, String>{},
    dynamic body,
    int timeoutSeconds = 40,
  }) async {
    final timeout = Duration(seconds: timeoutSeconds.clamp(1, 300));
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client
          .openUrl(method.trim().toUpperCase(), Uri.parse(url))
          .timeout(timeout);
      headers.forEach(request.headers.set);
      if (body != null) {
        if (body is List<int>) {
          request.add(body);
        } else if (body is String) {
          request.write(body);
        } else {
          request.headers.contentType ??= ContentType.json;
          request.write(jsonEncode(body));
        }
      }

      final response = await request.close().timeout(timeout);
      final bytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk))
          .timeout(timeout);
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });
      final text = utf8.decode(bytes, allowMalformed: true);
      dynamic json;
      try {
        json = jsonDecode(text);
      } catch (_) {
        json = null;
      }
      return <String, dynamic>{
        'statusCode': response.statusCode,
        'reasonPhrase': response.reasonPhrase,
        'headers': responseHeaders,
        'body': text,
        'bodyBytes': bytes,
        'json': json,
      };
    } finally {
      client.close(force: true);
    }
  }
}
