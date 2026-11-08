class QuoraCatalog {
  QuoraCatalog({required this.id, required this.name});

  final String id;
  final String name;

  factory QuoraCatalog.fromJson(Map<String, dynamic> json) {
    return QuoraCatalog(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class QuoraSession {
  QuoraSession({
    required this.id,
    required this.askUserName,
    required this.askUserPhoto,
    required this.summary,
    required this.snapshot,
    required this.topicName,
    required this.className,
    required this.unRead,
  });

  final String id;
  final String askUserName;
  final String askUserPhoto;
  final String summary;
  final String snapshot;
  final String topicName;
  final String className;
  final bool unRead;

  factory QuoraSession.fromJson(Map<String, dynamic> json) {
    return QuoraSession(
      id: (json['id'] ?? '').toString(),
      askUserName: (json['askUserName'] ?? '').toString(),
      askUserPhoto: (json['askUserPhoto'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      snapshot: (json['snapshot'] ?? '').toString(),
      topicName: (json['topicName'] ?? '').toString(),
      className: (json['class'] ?? '').toString(),
      unRead: json['unRead'] == true,
    );
  }
}

class QuoraMessage {
  QuoraMessage({
    required this.id,
    required this.userName,
    required this.sendTime,
    required this.snapshot,
    required this.content,
    required this.isPrimary,
    required this.userPhoto,
  });

  final String id;
  final String userName;
  final String sendTime;
  final String snapshot;
  final String content;
  final bool isPrimary;

  /// 消息里的头像；GetMessages 各版本字段名不统一，解析时逐个兜底，
  /// 都取不到时由详情页回退到会话的 askUserPhoto。
  final String userPhoto;

  factory QuoraMessage.fromJson(Map<String, dynamic> json) {
    var photo = '';
    for (final key in [
      'userPhoto',
      'photo',
      'picture',
      'headImg',
      'userImg',
      'senderPhoto',
      'askUserPhoto',
      'updateUserPhoto',
    ]) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        photo = value.toString();
        break;
      }
    }
    if (photo.isEmpty) {
      final sender = json['senderInfo'];
      if (sender is Map) {
        photo = (sender['picture'] ?? sender['photo'] ?? '').toString();
      }
    }
    return QuoraMessage(
      id: (json['id'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      sendTime: (json['sendTime'] ?? '').toString(),
      snapshot: (json['snapShot'] ?? json['snapshot'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      isPrimary: json['isPrimary'] == true,
      userPhoto: photo,
    );
  }
}
