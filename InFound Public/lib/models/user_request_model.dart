import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestModel {
  final String requestId;
  final String uid;
  final String type;
  final DateTime updatedAt;
  final DateTime createdAt;

  const UserRequestModel(
      {required this.requestId,
      required this.uid,
      required this.type,
      required this.updatedAt,
      required this.createdAt});

  toJson() {
    return {
      "requestId": requestId,
      "uid": uid,
      "type": type,
      "updatedAt": updatedAt,
      "createdAt": createdAt,
    };
  }

  static UserRequestModel empty() {
    return UserRequestModel(
      requestId: '',
      uid: '',
      type: '',
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  factory UserRequestModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserRequestModel(
        requestId: data.containsKey('requestId') ? data["requestId"] ?? '' : '',
        uid: data.containsKey('uid') ? data["uid"] ?? '' : '',
        type: data.containsKey('type') ? data["type"] ?? '' : '',
        updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() : DateTime.now(),
        createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() : DateTime.now(),
      );
    }
    return empty();
  }

  UserRequestModel copyWith({
    String? requestId,
    String? uid,
    String? type,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return UserRequestModel(
      requestId: requestId ?? this.requestId,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
