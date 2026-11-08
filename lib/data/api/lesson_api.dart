import '../../core/network/api_client.dart';
import '../models/lesson.dart';

/// 优客畅学接口（复刻 src/api/lesson.ts）
class LessonApi {
  LessonApi._();

  static dynamic _unwrapData(dynamic data) {
    if (data is Map && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is Map) return inner.containsKey('data') ? inner['data'] : inner;
      return inner;
    }
    if (data is Map && data.containsKey('result')) return data['result'];
    return data;
  }

  /// 在学课程（循环分页直到空）
  static Future<List<LessonCourse>> getLearningCourses() async {
    final all = <LessonCourse>[];
    for (var page = 1; page <= 50; page++) {
      final data = await ApiClient.instance
          .request('/SelfStudy/api/Learn/LearningCourses', query: {'page': page});
      final list = _unwrapData(data);
      if (list is! List || list.isEmpty) break;
      all.addAll(list
          .whereType<Map>()
          .map((e) => LessonCourse.fromJson(Map<String, dynamic>.from(e))));
      if (list.length < 10) break;
    }
    return all;
  }

  /// 课程章节目录
  static Future<List<LessonCatalog>> getCourseDetail(int courseId) async {
    final data = await ApiClient.instance.request(
      '/SelfStudy/api/Learn/CourseDetail',
      query: {'id': courseId},
    );
    final inner = _unwrapData(data);
    final catalogs = inner is Map ? inner['catalogs'] : null;
    if (catalogs is! List) return <LessonCatalog>[];
    return catalogs
        .whereType<Map>()
        .map((e) => LessonCatalog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 章节内容（HTML）
  static Future<String> readContent(String catalogId, int courseId) async {
    final data = await ApiClient.instance.request(
      '/SelfStudy/api/learn/readContent',
      query: {'catalogId': catalogId, 'courseId': courseId},
    );
    final inner = _unwrapData(data);
    if (inner is Map) return (inner['content'] ?? '').toString();
    return '';
  }
}
