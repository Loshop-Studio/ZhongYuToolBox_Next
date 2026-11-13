/// 学科 + 专栏树
class TopicSpecial {
  TopicSpecial({
    required this.topicId,
    required this.topicName,
    required this.cols,
  });

  final int topicId;
  final String topicName;
  final List<ColumnSummary> cols;

  factory TopicSpecial.fromJson(Map<String, dynamic> json) {
    final cols = json['cols'];
    return TopicSpecial(
      topicId: (json['topicId'] as num?)?.toInt() ?? 0,
      topicName: (json['topicName'] ?? '').toString(),
      cols: cols is List
          ? cols
                .whereType<Map>()
                .map(
                  (e) => ColumnSummary.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <ColumnSummary>[],
    );
  }
}

class ColumnSummary {
  ColumnSummary({required this.id, required this.name});

  final int id;
  final String name;

  factory ColumnSummary.fromJson(Map<String, dynamic> json) {
    return ColumnSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}

/// 文章更新消息
class AppMessage {
  const AppMessage({
    required this.id,
    required this.title,
    required this.creationTime,
    required this.isRead,
    required this.pageId,
    required this.senderName,
    required this.senderPhoto,
  });

  final String id;
  final String title;
  final String creationTime;
  final bool isRead;
  final int pageId;
  final String senderName;
  final String senderPhoto;

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    final parameter = json['parameter'];
    final sender = json['senderInfo'];
    return AppMessage(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      creationTime: (json['creationTime'] ?? '').toString(),
      isRead: json['isRead'] == true,
      pageId: parameter is Map ? (parameter['id'] as num?)?.toInt() ?? 0 : 0,
      senderName: sender is Map
          ? (sender['fullName'] ?? sender['userName'] ?? '').toString()
          : '',
      senderPhoto: sender is Map ? (sender['picture'] ?? '').toString() : '',
    );
  }
}

/// 公告详情（`/api/services/app/Notice/GetNoticeAsync` 的 NoticeBean）
class NoticeDetail {
  const NoticeDetail({
    required this.title,
    required this.content,
    required this.type,
    required this.targetCount,
    required this.readCount,
  });

  final String title;
  final String content;
  final int type;
  final int targetCount;
  final int readCount;

  factory NoticeDetail.fromJson(Map<String, dynamic> json) {
    return NoticeDetail(
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      type: (json['type'] as num?)?.toInt() ?? 0,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 我的收藏夹
class ColumnCatalog {
  ColumnCatalog({
    required this.id,
    required this.name,
    required this.collectCount,
  });

  final int id;
  final String name;
  final int collectCount;

  factory ColumnCatalog.fromJson(Map<String, dynamic> json) {
    return ColumnCatalog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      collectCount: (json['collectCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 收藏夹里的文章
class CatalogPageItem {
  CatalogPageItem({
    required this.id,
    required this.specialPageId,
    required this.title,
    required this.collectTime,
    required this.hits,
    required this.comments,
    required this.stars,
    required this.collects,
  });

  final int id;
  final int specialPageId;
  final String title;
  final String collectTime;
  final int hits;
  final int comments;
  final int stars;
  final int collects;

  factory CatalogPageItem.fromJson(Map<String, dynamic> json) {
    return CatalogPageItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      specialPageId: (json['specialPageId'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      collectTime: (json['collectTime'] ?? json['creationTime'] ?? '')
          .toString(),
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      collects: (json['collects'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 专栏文章摘要
class ColumnPageItem {
  ColumnPageItem({
    required this.id,
    required this.title,
    required this.publishTime,
    required this.hits,
    required this.comments,
    required this.stars,
    required this.isRead,
    required this.isTop,
  });

  final int id;
  final String title;
  final String publishTime;
  final int hits;
  final int comments;
  final int stars;
  final bool isRead;
  final bool isTop;

  factory ColumnPageItem.fromJson(Map<String, dynamic> json) {
    return ColumnPageItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      publishTime: (json['publishTime'] ?? json['creationTime'] ?? '')
          .toString(),
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      isRead: json['isRead'] == true,
      isTop: json['isTop'] == true,
    );
  }
}

/// 文章详情（content 为 HTML）
class ColumnPageDetail {
  ColumnPageDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModificationTime,
    required this.stars,
    required this.collects,
    required this.comments,
    required this.hits,
    required this.publisher,
  });

  final int id;
  final String title;
  final String content;
  final String lastModificationTime;
  final int stars;
  final int collects;
  final int comments;
  final int hits;
  final String publisher;

  factory ColumnPageDetail.fromJson(Map<String, dynamic> json) {
    final creator = json['creatorUser'];
    return ColumnPageDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      lastModificationTime:
          (json['lastModificationTime'] ?? json['creationTime'] ?? '')
              .toString(),
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      collects: (json['collects'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      publisher: creator is Map ? (creator['fullName'] ?? '').toString() : '',
    );
  }
}

/// 专栏文章评论。
class ColumnComment {
  const ColumnComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPicture,
    required this.commentTime,
    required this.content,
    required this.isActive,
    required this.isDeleted,
    required this.allowReply,
    required this.replies,
  });

  final int id;
  final int userId;
  final String userName;
  final String userPicture;
  final String commentTime;
  final String content;
  final bool isActive;
  final bool isDeleted;
  final bool allowReply;
  final List<ColumnCommentReply> replies;

  factory ColumnComment.fromJson(Map<String, dynamic> json) {
    final replies = json['replies'];
    return ColumnComment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['commentUserId'] as num?)?.toInt() ?? 0,
      userName: (json['commentUserFullName'] ?? '').toString().trim(),
      userPicture: (json['commentUserPicture'] ?? '').toString(),
      commentTime: (json['commentTime'] ?? '').toString(),
      content: (json['comment'] ?? '').toString(),
      isActive: json['isActive'] == true,
      isDeleted: json['isDeleted'] == true,
      allowReply: json['allowReply'] == true,
      replies: replies is List
          ? replies
                .whereType<Map>()
                .map(
                  (e) =>
                      ColumnCommentReply.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <ColumnCommentReply>[],
    );
  }
}

/// 专栏文章评论下的回复。不同版本服务端字段名略有差异，因此保留兼容字段。
class ColumnCommentReply {
  const ColumnCommentReply({
    required this.id,
    required this.userName,
    required this.userPicture,
    required this.replyTime,
    required this.content,
  });

  final int id;
  final String userName;
  final String userPicture;
  final String replyTime;
  final String content;

  factory ColumnCommentReply.fromJson(Map<String, dynamic> json) {
    return ColumnCommentReply(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName:
          (json['replyUserFullName'] ??
                  json['commentUserFullName'] ??
                  json['userFullName'] ??
                  '')
              .toString()
              .trim(),
      userPicture:
          (json['replyUserPicture'] ??
                  json['commentUserPicture'] ??
                  json['userPicture'] ??
                  '')
              .toString(),
      replyTime:
          (json['replyTime'] ??
                  json['commentTime'] ??
                  json['creationTime'] ??
                  '')
              .toString(),
      content: (json['reply'] ?? json['comment'] ?? json['content'] ?? '')
          .toString(),
    );
  }
}
