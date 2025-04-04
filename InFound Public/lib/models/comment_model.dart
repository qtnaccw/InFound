import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infound/models/reply_model.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String comment;
  final String? image;
  final int numUpvotes;
  final List<String> repliesId;
  final List<ReplyModel> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel(
      {required this.commentId,
      required this.postId,
      required this.userId,
      required this.comment,
      this.image,
      required this.numUpvotes,
      required this.repliesId,
      required this.replies,
      required this.createdAt,
      required this.updatedAt});

  toJson() {
    return {
      "commentId": commentId,
      "postId": postId,
      "userId": userId,
      "comment": comment,
      "image": image,
      "numUpvotes": numUpvotes,
      "repliesId": repliesId,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };
  }

  static empty() {
    return CommentModel(
        commentId: '',
        postId: '',
        userId: '',
        comment: '',
        image: '',
        numUpvotes: 0,
        repliesId: [],
        replies: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory CommentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, List<ReplyModel> replies) {
    if (document.data() != null) {
      final data = document.data()!;
      return CommentModel(
          commentId: data.containsKey('commentId') ? data["commentId"] ?? '' : '',
          postId: data.containsKey('postId') ? data["postId"] ?? '' : '',
          userId: data.containsKey('userId') ? data["userId"] ?? '' : '',
          comment: data.containsKey('comment') ? data["comment"] ?? '' : '',
          image: data.containsKey('image') ? data["image"] ?? '' : '',
          numUpvotes: data.containsKey('numUpvotes') ? data["numUpvotes"] ?? 0 : 0,
          repliesId: data.containsKey('repliesId') ? List<String>.from(data["repliesId"]) : [],
          replies: replies,
          createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() : DateTime.now(),
          updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() : DateTime.now());
    }
    return empty();
  }

  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? comment,
    String? image,
    int? numUpvotes,
    List<String>? repliesId,
    List<ReplyModel>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      image: image ?? this.image,
      numUpvotes: numUpvotes ?? this.numUpvotes,
      repliesId: repliesId ?? this.repliesId,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
