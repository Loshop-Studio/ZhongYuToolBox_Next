import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/features/assessment/exam_review_store.dart';

void main() {
  group('ExamReviewStore.canAnalyzeWrongQuestions', () {
    test('未完成测评的空分析数据不可用于识别错题', () {
      expect(ExamReviewStore.canAnalyzeWrongQuestions(null), isFalse);
      expect(ExamReviewStore.canAnalyzeWrongQuestions({}), isFalse);
      expect(
        ExamReviewStore.canAnalyzeWrongQuestions({
          'testGroupAnalysis': <dynamic>[],
        }),
        isFalse,
      );
    });

    test('存在题目分析分组时可以识别错题', () {
      expect(
        ExamReviewStore.canAnalyzeWrongQuestions({
          'testGroupAnalysis': [
            {'testQuestionAnalysis': <dynamic>[]},
          ],
        }),
        isTrue,
      );
    });
  });
}
