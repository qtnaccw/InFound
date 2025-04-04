import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infound/models/comment_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String type;
  final String title;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? itemColor;
  final String? itemSize;
  final String? itemBrand;
  final List<String> imagesURL;
  final int numUpvotes;
  final int numComments;
  final List<CommentModel> comments;
  final List<String> commentsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel(
      {required this.postId,
      required this.userId,
      required this.type,
      required this.title,
      this.description,
      this.location,
      this.latitude,
      this.longitude,
      this.radius,
      this.itemColor,
      this.itemSize,
      this.itemBrand,
      required this.imagesURL,
      required this.numUpvotes,
      required this.numComments,
      required this.comments,
      required this.commentsId,
      required this.createdAt,
      required this.updatedAt});

  toJson() {
    return {
      "postId": postId,
      "userId": userId,
      "type": type,
      "title": title,
      "description": description,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "itemColor": itemColor,
      "itemSize": itemSize,
      "itemBrand": itemBrand,
      "imagesURL": imagesURL,
      "numUpvotes": numUpvotes,
      "numComments": numComments,
      "commentsId": commentsId,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };
  }

  static empty() {
    return PostModel(
        postId: '',
        userId: '',
        type: '',
        title: '',
        description: '',
        location: '',
        latitude: null,
        longitude: null,
        radius: null,
        itemColor: '',
        itemSize: '',
        itemBrand: '',
        imagesURL: [],
        numUpvotes: 0,
        numComments: 0,
        comments: [],
        commentsId: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, List<CommentModel> comments) {
    if (document.data() != null) {
      final data = document.data()!;
      PostModel newPost = PostModel(
        postId: data.containsKey('postId') ? data["postId"] ?? '' : '',
        userId: data.containsKey('userId') ? data["userId"] ?? '' : '',
        type: data.containsKey('type') ? data["type"] ?? '' : '',
        title: data.containsKey('title') ? data["title"] ?? '' : '',
        description: data.containsKey('description') ? data["description"] ?? '' : '',
        location: data.containsKey('location') ? data["location"] ?? '' : '',
        latitude: data.containsKey('latitude') ? data["latitude"] ?? null : null,
        longitude: data.containsKey('longitude') ? data["longitude"] ?? null : null,
        radius: data.containsKey('radius') ? data["radius"] ?? null : null,
        itemColor: data.containsKey('itemColor') ? data["itemColor"] ?? '' : '',
        itemSize: data.containsKey('itemSize') ? data["itemSize"] ?? '' : '',
        itemBrand: data.containsKey('itemBrand') ? data["itemBrand"] ?? '' : '',
        imagesURL: data.containsKey('imagesURL') ? List<String>.from(data["imagesURL"]) : [],
        numUpvotes: data.containsKey('numUpvotes') ? data["numUpvotes"] ?? 0 : 0,
        numComments: data.containsKey('numComments') ? data["numComments"] ?? 0 : 0,
        comments: comments,
        commentsId: data.containsKey('commentsId') ? List<String>.from(data["commentsId"]) : [],
        createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() : DateTime.now(),
        updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() : DateTime.now(),
      );
      return newPost;
    } else {
      return empty();
    }
  }

  PostModel copyWith({
    String? postId,
    String? userId,
    String? type,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    double? radius,
    String? itemColor,
    String? itemSize,
    String? itemBrand,
    List<String>? imagesURL,
    int? numUpvotes,
    int? numComments,
    List<CommentModel>? comments,
    List<String>? commentsId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        radius: radius ?? this.radius,
        itemColor: itemColor ?? this.itemColor,
        itemSize: itemSize ?? this.itemSize,
        itemBrand: itemBrand ?? this.itemBrand,
        imagesURL: imagesURL ?? this.imagesURL,
        numUpvotes: numUpvotes ?? this.numUpvotes,
        numComments: numComments ?? this.numComments,
        comments: comments ?? this.comments,
        commentsId: commentsId ?? this.commentsId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }
}
