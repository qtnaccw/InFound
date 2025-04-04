import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String postId;
  final String commentId;
  final String reporteeId;
  final String reporterId;
  final String targetId;
  final String reason;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.reportId,
    required this.postId,
    required this.commentId,
    required this.reporteeId,
    required this.reporterId,
    required this.targetId,
    required this.reason,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  toJson() {
    return {
      'reportId': reportId,
      'postId': postId,
      'commentId': commentId,
      'reporteeId': reporteeId,
      'reporterId': reporterId,
      'targetId': targetId,
      'reason': reason,
      'type': type,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static empty() {
    return ReportModel(
      reportId: '',
      postId: '',
      commentId: '',
      reporteeId: '',
      reporterId: '',
      targetId: '',
      reason: '',
      type: '',
      status: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory ReportModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return ReportModel(
        reportId: data.containsKey('reportId') ? data['reportId'] ?? '' : '',
        postId: data.containsKey('postId') ? data['postId'] ?? '' : '',
        commentId: data.containsKey('commentId') ? data['commentId'] ?? '' : '',
        reporteeId: data.containsKey('reporteeId') ? data['reporteeId'] ?? '' : '',
        reporterId: data.containsKey('reporterId') ? data['reporterId'] ?? '' : '',
        targetId: data.containsKey('targetId') ? data['targetId'] ?? '' : '',
        reason: data.containsKey('reason') ? data['reason'] ?? '' : '',
        type: data.containsKey('type') ? data['type'] ?? '' : '',
        status: data.containsKey('status') ? data['status'] ?? '' : '',
        createdAt: data.containsKey('createdAt') ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
        updatedAt: data.containsKey('updatedAt') ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
      );
    }
    return empty();
  }

  ReportModel copyWith(
      {String? reportId,
      String? postId,
      String? commentId,
      String? reporteeId,
      String? reporterId,
      String? targetId,
      String? reason,
      String? type,
      String? status,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      reporteeId: reporteeId ?? this.reporteeId,
      reporterId: reporterId ?? this.reporterId,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
