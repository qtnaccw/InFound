import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  final String replyId;
  final String commentId;
  final String postId;
  final String userId;
  final String comment;
  final String? image;
  final int numUpvotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReplyModel(
      {required this.replyId,
      required this.commentId,
      required this.postId,
      required this.userId,
      required this.comment,
      this.image,
      required this.numUpvotes,
      required this.createdAt,
      required this.updatedAt});

  toJson() {
    return {
      "replyId": replyId,
      "commentId": commentId,
      "postId": postId,
      "userId": userId,
      "comment": comment,
      "image": image,
      "numUpvotes": numUpvotes,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };
  }

  static empty() {
    return ReplyModel(
        replyId: '',
        commentId: '',
        postId: '',
        userId: '',
        comment: '',
        image: '',
        numUpvotes: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory ReplyModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return ReplyModel(
          replyId: data.containsKey('replyId') ? data["replyId"] ?? '' : '',
          commentId: data.containsKey('commentId') ? data["commentId"] ?? '' : '',
          postId: data.containsKey('postId') ? data["postId"] ?? '' : '',
          userId: data.containsKey('userId') ? data["userId"] ?? '' : '',
          comment: data.containsKey('comment') ? data["comment"] ?? '' : '',
          image: data.containsKey('image') ? data["image"] ?? '' : '',
          numUpvotes: data.containsKey('numUpvotes') ? data["numUpvotes"] ?? 0 : 0,
          createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() ?? DateTime.now() : DateTime.now(),
          updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() ?? DateTime.now() : DateTime.now());
    }
    return empty();
  }

  ReplyModel copyWith({
    String? replyId,
    String? commentId,
    String? postId,
    String? userId,
    String? comment,
    String? image,
    int? numUpvotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReplyModel(
      replyId: replyId ?? this.replyId,
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      image: image ?? this.image,
      numUpvotes: numUpvotes ?? this.numUpvotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
