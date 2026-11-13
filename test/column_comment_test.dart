import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/data/models/column.dart';

void main() {
  test('解析专栏评论及回复', () {
    final comment = ColumnComment.fromJson({
      'id': 242049,
      'commentUserId': 30875,
      'commentUserFullName': '吴翌轩 ',
      'commentUserPicture': 'https://example.com/avatar.jpg',
      'commentTime': '2026-11-13 20:45:27',
      'comment': '111',
      'isActive': false,
      'isDeleted': false,
      'allowReply': true,
      'replies': [
        {
          'id': 1,
          'replyUserFullName': '回复者',
          'replyTime': '2026-11-13 20:46:00',
          'reply': '回复内容',
        },
      ],
    });

    expect(comment.id, 242049);
    expect(comment.userName, '吴翌轩');
    expect(comment.content, '111');
    expect(comment.allowReply, isTrue);
    expect(comment.isActive, isFalse);
    expect(comment.replies, hasLength(1));
    expect(comment.replies.single.userName, '回复者');
    expect(comment.replies.single.content, '回复内容');
  });

  test('回复字段兼容评论结构', () {
    final reply = ColumnCommentReply.fromJson({
      'id': 2,
      'commentUserFullName': '兼容用户',
      'commentTime': '2026-11-13 20:47:00',
      'comment': '兼容内容',
    });

    expect(reply.userName, '兼容用户');
    expect(reply.replyTime, '2026-11-13 20:47:00');
    expect(reply.content, '兼容内容');
  });
}
