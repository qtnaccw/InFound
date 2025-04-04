import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userName;
  final String email;
  final bool isEmailPublic;
  final String profileURL;
  final String bio;
  final String name;
  final bool isNamePublic;
  final String phone;
  final bool isPhonePublic;
  final String location;
  final bool isLocationPublic;
  final bool isVerified;
  final bool isAdmin;
  final List<String> posts;
  final List<String> comments;
  final List<String> replies;
  final List<String> notifications;
  final List<String> upvotes;
  final List<String> bookmarks;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel(
      {required this.uid,
      required this.userName,
      required this.email,
      required this.isEmailPublic,
      this.profileURL = '',
      required this.bio,
      required this.name,
      required this.isNamePublic,
      required this.phone,
      required this.isPhonePublic,
      required this.location,
      required this.isLocationPublic,
      required this.isVerified,
      required this.isAdmin,
      required this.posts,
      required this.comments,
      required this.replies,
      required this.notifications,
      required this.upvotes,
      required this.bookmarks,
      required this.badges,
      required this.createdAt,
      required this.updatedAt});

  toJson() {
    return {
      "uid": uid,
      "userName": userName,
      "email": email,
      "isEmailPublic": isEmailPublic,
      "profileURL": profileURL,
      "bio": bio,
      "name": name,
      "isNamePublic": isNamePublic,
      "phone": phone,
      "isPhonePublic": isPhonePublic,
      "location": location,
      "isLocationPublic": isLocationPublic,
      "isVerified": isVerified,
      "isAdmin": isAdmin,
      "posts": posts,
      "comments": comments,
      "replies": replies,
      "notifications": notifications,
      "upvotes": upvotes,
      "bookmarks": bookmarks,
      "badges": badges,
      "createdAt": createdAt,
      "updatedAt": updatedAt
    };
  }

  static UserModel empty() => UserModel(
      uid: '',
      userName: '',
      email: '',
      isEmailPublic: false,
      profileURL: '',
      bio: '',
      name: '',
      isNamePublic: false,
      phone: '',
      isPhonePublic: false,
      location: '',
      isLocationPublic: false,
      isVerified: false,
      isAdmin: false,
      posts: [],
      comments: [],
      replies: [],
      notifications: [],
      upvotes: [],
      bookmarks: [],
      badges: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now());

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        uid: data.containsKey('uid') ? data["uid"] ?? '' : '',
        userName: data.containsKey('userName') ? data["userName"] ?? '' : '',
        email: data.containsKey('email') ? data["email"] ?? '' : '',
        isEmailPublic: data.containsKey('isEmailPublic') ? data["isEmailPublic"] ?? false : false,
        profileURL: data.containsKey('profileURL') ? data["profileURL"] ?? '' : '',
        bio: data.containsKey('bio') ? data["bio"] ?? '' : '',
        name: data.containsKey('name') ? data["name"] ?? '' : '',
        isNamePublic: data.containsKey('isNamePublic') ? data["isNamePublic"] ?? false : false,
        phone: data.containsKey('phone') ? data["phone"] ?? '' : '',
        isPhonePublic: data.containsKey('isPhonePublic') ? data["isPhonePublic"] ?? false : false,
        location: data.containsKey('location') ? data["location"] ?? '' : '',
        isLocationPublic: data.containsKey('isLocationPublic') ? data["isLocationPublic"] ?? false : false,
        isVerified: data.containsKey('isVerified') ? data["isVerified"] ?? false : false,
        isAdmin: data.containsKey('isAdmin') ? data["isAdmin"] ?? false : false,
        posts: data.containsKey('posts') ? List<String>.from(data["posts"]) : [],
        comments: data.containsKey('comments') ? List<String>.from(data["comments"]) : [],
        replies: data.containsKey('replies') ? List<String>.from(data["replies"]) : [],
        notifications: data.containsKey('notifications') ? List<String>.from(data["notifications"]) : [],
        upvotes: data.containsKey('upvotes') ? List<String>.from(data["upvotes"]) : [],
        bookmarks: data.containsKey('bookmarks') ? List<String>.from(data["bookmarks"]) : [],
        badges: data.containsKey('badges') ? List<String>.from(data["badges"]) : [],
        createdAt: data.containsKey('createdAt') ? data['createdAt'].toDate() : DateTime.now(),
        updatedAt: data.containsKey('updatedAt') ? data['updatedAt'].toDate() : DateTime.now(),
      );
    }
    return empty();
  }

  UserModel copyWith({
    String? uid,
    String? userName,
    String? email,
    bool? isEmailPublic,
    String? profileURL,
    String? bio,
    String? name,
    bool? isNamePublic,
    String? phone,
    bool? isPhonePublic,
    String? location,
    bool? isLocationPublic,
    bool? isVerified,
    bool? isAdmin,
    List<String>? posts,
    List<String>? comments,
    List<String>? replies,
    List<String>? notifications,
    List<String>? upvotes,
    List<String>? bookmarks,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      isEmailPublic: isEmailPublic ?? this.isEmailPublic,
      profileURL: profileURL ?? this.profileURL,
      bio: bio ?? this.bio,
      name: name ?? this.name,
      isNamePublic: isNamePublic ?? this.isNamePublic,
      phone: phone ?? this.phone,
      isPhonePublic: isPhonePublic ?? this.isPhonePublic,
      location: location ?? this.location,
      isLocationPublic: isLocationPublic ?? this.isLocationPublic,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      replies: replies ?? this.replies,
      notifications: notifications ?? this.notifications,
      upvotes: upvotes ?? this.upvotes,
      bookmarks: bookmarks ?? this.bookmarks,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
