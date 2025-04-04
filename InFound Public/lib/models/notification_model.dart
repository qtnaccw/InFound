import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notifId;
  final String userId;
  final String senderUsername;
  final String senderUid;
  final String type;
  final String targetId;
  final String postId;
  final String notifContent;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel(
      {required this.notifId,
      required this.userId,
      required this.senderUsername,
      required this.senderUid,
      required this.type,
      required this.targetId,
      required this.postId,
      required this.notifContent,
      required this.read,
      required this.createdAt,
      required this.updatedAt});

  toJson() {
    return {
      "notifId": notifId,
      "userId": userId,
      "senderUsername": senderUsername,
      "senderUid": senderUid,
      "type": type,
      "targetId": targetId,
      "postId": postId,
      "notifContent": notifContent,
      "read": read,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };
  }

  static empty() {
    return NotificationModel(
        notifId: '',
        userId: '',
        senderUsername: '',
        senderUid: '',
        type: '',
        targetId: '',
        postId: '',
        notifContent: '',
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory NotificationModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return NotificationModel(
          notifId: data.containsKey('notifId') ? data["notifId"] ?? '' : '',
          userId: data.containsKey('userId') ? data["userId"] ?? '' : '',
          senderUsername: data.containsKey('senderUsername') ? data["senderUsername"] ?? '' : '',
          senderUid: data.containsKey('senderUid') ? data["senderUid"] ?? '' : '',
          type: data.containsKey('type') ? data["type"] ?? '' : '',
          targetId: data.containsKey('targetId') ? data["targetId"] ?? '' : '',
          postId: data.containsKey('postId') ? data["postId"] ?? '' : '',
          notifContent: data.containsKey('notifContent') ? data["notifContent"] ?? '' : '',
          read: data.containsKey('read') ? data["read"] ?? false : false,
          createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() : DateTime.now(),
          updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() : DateTime.now());
    }
    return empty();
  }

  NotificationModel copyWith({
    String? notifId,
    String? userId,
    String? senderUsername,
    String? senderUid,
    String? senderPhotoUrl,
    String? type,
    String? targetId,
    String? postId,
    String? notifContent,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      notifId: notifId ?? this.notifId,
      userId: userId ?? this.userId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderUid: senderUid ?? this.senderUid,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      postId: postId ?? this.postId,
      notifContent: notifContent ?? this.notifContent,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
