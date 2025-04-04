import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infound/main.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/comment_model.dart';
import 'package:infound/models/notification_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/reply_model.dart';
import 'package:infound/models/report_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';

class DatabaseRepository extends GetxController {
  static DatabaseRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _rd = FirebaseDatabase.instance;

  Future createUser({required UserModel user}) async {
    await _db
        .collection("users")
        .doc(user.uid)
        .set(user.toJson())
        .then((val) async {
      await createUserRD(user: user);
      DatabaseRepository.instance.grantBadge(
          userId: user.uid, badgeId: "d7564340-e176-11ef-a3ae-65da61cb9165");
      String emailSubject = "[InFound] Welcome to InFound!";
      String emailText =
          """Dear ${user.userName}, Welcome to InFound! We’re excited to have you join our community dedicated to helping people reconnect with their lost items. Whether you're searching for something you lost or looking to return a found item, InFound makes the process easy and efficient. Here’s what you can do on InFound: Create posts for lost or found items with detailed descriptions and images. Search & filter posts by category, location, and item details. Engage with the community by commenting, replying, and upvoting. Get notified when someone interacts with your post. Bookmark important posts for easy reference later. To get started, log in to your account and explore the platform: https://infound.web.app. If you have any questions or need assistance, feel free to reach out to our support team. Thank you for being a part of InFound! Let's help each other find what matters. Best regards, InFound Team""";
      String emailHtml = """
<div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
  <div style="margin:50px auto;width:70%;padding:20px 0">
    <div style="border-bottom:1px solid #eee">
      <a href="https://infound.web.app" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
        <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundFull.png?alt=media&token=cafd8ede-c425-48cc-8d7d-c07e8f3a661f" width="auto" height="50" alt="Icon">
      </a>
    </div>
    <p style="font-size:1.1em">Dear ${user.userName},</p>
    <p>Welcome to <b style="color:#5BB6AE;">InFound</b>! We’re excited to have you join our community dedicated to helping people reconnect with their lost items. Whether you're searching for something you lost or looking to return a found item, InFound makes the process easy and efficient.</p>
    <p style="margin: 0 0;margin-left: 24px; padding: 4px 0;line-height: 1.5;">Here’s what you can do on <b style="color:#5BB6AE;">InFound</b>:
<br>✅ Create posts for lost or found items with detailed descriptions and images.
<br>✅ Search & filter posts by category, location, and item details.
<br>✅ Engage with the community by commenting, replying, and upvoting.
<br>✅ Get notified when someone interacts with your post.
<br>✅ Bookmark important posts for easy reference later.</p>
    <p>To get started, log in to your account and explore the platform:</p>
    <a href="https://infound.web.app" style="text-decoration: none;"><h2 style="background: #5BB6AE;width: max-content;padding: 0 16px;color: #fff;border-radius: 8px;font-size:18px;text-decoration: none;">Open InFound</h2></a>
    <p>If you have any questions or need assistance, feel free to reach out to our support team.
      <br>Thank you for being a part of <b style="color:#5BB6AE;">InFound</b>! Let's help each other find what matters.</p>
    <p><br />Best regards,<br />InFound Team</p>
    <hr style="border:none;border-top:1px solid #eee" />
    <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
      <a href="https://infound.web.app" style="float:left;padding:8px 16px;font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
        <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundIcon.png?alt=media&token=c91d7209-08c2-4f3b-859b-424986f7ee47" width="auto" height="50" alt="Icon">
      </a>
      <div style="float:right;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
        <p>InFound</p>
        <p>Angeles City, Pampanga</p>
        <p>Philippines</p>
      </div>
    </div>
  </div>
</div>""";
      createEmail(
          recipients: [user.email],
          subject: emailSubject,
          text: emailText,
          html: emailHtml);
      AppPopups.successSnackBar(
          title: "Welcome ${user.userName}!",
          message: "Your account has been created.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message:
              "Unable to create user for ${user.email}. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createUserRD({required UserModel user}) async {
    await _rd.ref("users/${user.uid}").set({
      "fullText":
          "${user.uid != '' ? "&uid=" + user.uid : ""}${user.userName != '' ? "&username=" + user.userName.toUpperCase() : ""}${user.name != '' ? "&name=" + user.name.toUpperCase() : ""}${user.email != '' ? "&email=" + user.email.toUpperCase() : ""}${user.phone != '' ? "&phone=" + user.phone.toUpperCase() : ""}${user.bio != '' ? "&bio=" + user.bio.toUpperCase() : ""}${user.location != '' ? "&location=" + user.location.toUpperCase() : ""}${user.posts.isNotEmpty ? "&posts=" + user.posts.join("&") : ""}${user.comments.isNotEmpty ? "&comments=" + user.comments.join("&") : ""}${user.replies.isNotEmpty ? "&replies=" + user.replies.join("&") : ""}",
    }).then((_) {
      printDebug("User ${user.uid} created in Realtime Database");
    }).catchError((err, stackTrace) {
      printDebug(err.toString());
    });
  }

  Future createPost({required PostModel post}) async {
    await _db
        .collection("posts")
        .doc(post.postId)
        .set(post.toJson())
        .then((val) async {
      await createPostRD(post: post);
      // Add post to user's posts list
      List<String> currentPosts =
          AuthenticationRepository.instance.currentUserModel.value!.posts;
      if (currentPosts.isEmpty) {
        grantBadge(
            userId:
                AuthenticationRepository.instance.currentUserModel.value!.uid,
            badgeId: "b49157a0-f2d3-11ef-9a40-e59eda3d52a5");
      }
      currentPosts.add(post.postId);
      UserModel? user = AuthenticationRepository
          .instance.currentUserModel.value!
          .copyWith(posts: currentPosts, updatedAt: DateTime.now());
      await updateUser(user: user, silentUpdate: true).then((value) {
        AuthenticationRepository.instance.currentUserModel.value = user;
      });

      AppPopups.successSnackBar(
          title: "InFound", message: "You created a post.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to create post. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createPostRD({required PostModel post}) async {
    await _rd.ref("posts/${post.postId}").set({
      "fullText":
          "${post.postId != '' ? "&postId=" + post.postId : ""}${post.userId != '' ? "&userId=" + post.userId : ""}${post.title != '' ? "&title=" + post.title.toUpperCase() : ""}${post.description != null && post.description != '' ? "&description=" + post.description!.toUpperCase() : ""}${post.location != null && post.location != '' ? "&location=" + post.location!.toUpperCase() : ""}${post.latitude != null ? "&latitude=" + post.latitude!.toString().toUpperCase() : ""}${post.longitude != null ? "&longitude=" + post.longitude!.toString().toUpperCase() : ""}${post.radius != null ? "&radius=" + post.radius.toString().toUpperCase() : ""}${post.itemColor != null && post.itemColor != '' ? "&itemColor=" + post.itemColor!.toUpperCase() : ""}${post.itemSize != null && post.itemSize != '' ? "&itemSize=" + post.itemSize!.toUpperCase() : ""}${post.itemBrand != null && post.itemBrand != '' ? "&itemBrand=" + post.itemBrand!.toUpperCase() : ""}${post.commentsId.isNotEmpty ? "&commentsId=" + post.commentsId.join("&") : ""}",
      "latitude": post.latitude,
      "longitude": post.longitude,
      "radius": post.radius
    }).then((val) {
      printDebug("Post ${post.postId} created in Realtime Database");
    }).catchError((err, stackTrace) {
      printDebug(err.toString());
    });
  }

  Future createComment({required CommentModel comment}) async {
    await _db
        .collection("posts")
        .doc(comment.postId)
        .collection("comments")
        .doc(comment.commentId)
        .set(comment.toJson())
        .then((val) async {
      // Add comment to user's comments list
      List<String> currentComments =
          AuthenticationRepository.instance.currentUserModel.value!.comments;
      if (!AuthenticationRepository.instance.currentUserModel.value!.badges
          .contains('41304b40-f2d3-11ef-9a40-e59eda3d52a5')) {
        grantBadge(
            userId:
                AuthenticationRepository.instance.currentUserModel.value!.uid,
            badgeId: "41304b40-f2d3-11ef-9a40-e59eda3d52a5");
      }
      currentComments.add(
          "${comment.postId}${AppConstants.tCommentSeparator}${comment.commentId}");
      UserModel? user = AuthenticationRepository
          .instance.currentUserModel.value!
          .copyWith(comments: currentComments, updatedAt: DateTime.now());
      await updateUser(user: user, silentUpdate: true);
      AuthenticationRepository.instance.currentUserModel.value = user;

      // Update post's numComments and commentsId
      PostModel? post = await getSpecificPost(
        postId: comment.postId,
      );
      List<String> currentCommentsId = post!.commentsId;
      currentCommentsId.add(comment.commentId);
      PostModel updatedPost = post.copyWith(
          numComments: post.numComments + 1,
          commentsId: currentCommentsId,
          updatedAt: DateTime.now());
      await updatePost(post: updatedPost, silentUpdate: true);

      // Notify post owner
      if (post.userId !=
          AuthenticationRepository.instance.currentUserModel.value!.uid) {
        NotificationModel notif = NotificationModel(
          notifId: uuid.v1(),
          userId: post.userId,
          senderUid:
              AuthenticationRepository.instance.currentUserModel.value!.uid,
          senderUsername: AuthenticationRepository
              .instance.currentUserModel.value!.userName,
          targetId: comment.commentId,
          postId: comment.postId,
          notifContent: 'commented on your post: "${comment.comment}".',
          type: "COMMENT",
          read: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await createNotification(notification: notif, silent: true);
        UserModel? postUser = await getUserInfo(id: post.userId);
        if (postUser != null) {
          String emailSubject =
              "[InFound] ${AuthenticationRepository.instance.currentUserModel.value!.userName} commented on your post";
          String emailText =
              """Hi ${postUser.userName}, ${AuthenticationRepository.instance.currentUserModel.value!.userName} commented on your post "${post.title}". ${AuthenticationRepository.instance.currentUserModel.value!.userName} commented: "${comment.comment}". You can view the comment by clicking this link: https://infound.web.app/post/${comment.postId}. Best regards, InFound Team""";
          String emailHtml = """
            <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
              <div style="margin:50px auto;width:70%;padding:20px 0">
                <div style="border-bottom:1px solid #eee">
                  <a href="https://infound.web.app" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
                    <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundFull.png?alt=media&token=cafd8ede-c425-48cc-8d7d-c07e8f3a661f" width="auto" height="50" alt="Icon">
                  </a>
                </div>
                <p style="font-size:1.1em">Hi ${postUser.userName},</p>
                <p>${AuthenticationRepository.instance.currentUserModel.value!.userName} just commented on your post "${post.title}".</p>
                <p style="margin: 0 0;margin-left: 24px; padding: 4px 0;line-height: 1.5;">${AuthenticationRepository.instance.currentUserModel.value!.userName} commented: "${comment.comment}".</p>
                <p>You can view the comment by clicking the link below:</p>
                <a href="https://infound.web.app/post/${comment.postId}" style="text-decoration: none;"><h2 style="background: #5BB6AE;width: max-content;padding: 0 16px;color: #fff;border-radius: 8px;font-size:18px;">Open InFound</h2></a>
                
                <p><br />Best regards,<br />InFound Team</p>
                <hr style="border:none;border-top:1px solid #eee" />
                <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
                  <a href="https://infound.web.app" style="float:left;padding:8px 16px;font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
                    <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundIcon.png?alt=media&token=c91d7209-08c2-4f3b-859b-424986f7ee47" width="auto" height="50" alt="Icon">
                  </a>
                  <div style="float:right;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
                    <p>InFound</p>
                    <p>Angeles City, Pampanga</p>
                    <p>Philippines</p>
                  </div>
                </div>
              </div>
            </div>""";
          createEmail(
              recipients: [postUser.email],
              subject: emailSubject,
              text: emailText,
              html: emailHtml);
        }
      }

      AppPopups.successSnackBar(
          title: "InFound", message: "You commented to a post.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to post comment. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createReply({required ReplyModel reply}) async {
    await _db
        .collection("posts")
        .doc(reply.postId)
        .collection("comments")
        .doc(reply.commentId)
        .collection("replies")
        .doc(reply.replyId)
        .set(reply.toJson())
        .then((val) async {
      // Add reply to user's replies list
      List<String> currentReplies =
          AuthenticationRepository.instance.currentUserModel.value!.replies;
      if (!AuthenticationRepository.instance.currentUserModel.value!.badges
          .contains('41304b40-f2d3-11ef-9a40-e59eda3d52a5')) {
        grantBadge(
            userId:
                AuthenticationRepository.instance.currentUserModel.value!.uid,
            badgeId: "41304b40-f2d3-11ef-9a40-e59eda3d52a5");
      }
      currentReplies.add(
          "${reply.postId}${AppConstants.tCommentSeparator}${reply.commentId}${AppConstants.tReplySeparator}${reply.replyId}");
      UserModel? user = AuthenticationRepository
          .instance.currentUserModel.value!
          .copyWith(replies: currentReplies, updatedAt: DateTime.now());
      await updateUser(user: user, silentUpdate: true);
      AuthenticationRepository.instance.currentUserModel.value = user;
      // Update comment's numReplies
      CommentModel? comment = await getCommentById(
          postId: reply.postId, commentId: reply.commentId);
      List<String> currentRepliesId = comment!.repliesId;
      currentRepliesId.add(reply.replyId);
      CommentModel updatedComment = comment.copyWith(
          repliesId: currentRepliesId, updatedAt: DateTime.now());
      await updateComment(comment: updatedComment, silentUpdate: true);
      // Notify comment owner
      if (comment.userId !=
          AuthenticationRepository.instance.currentUserModel.value!.uid) {
        NotificationModel notif = NotificationModel(
          notifId: uuid.v1(),
          userId: comment.userId,
          senderUid:
              AuthenticationRepository.instance.currentUserModel.value!.uid,
          senderUsername: AuthenticationRepository
              .instance.currentUserModel.value!.userName,
          targetId: reply.replyId,
          postId: reply.postId,
          notifContent: 'replied to your comment: "${reply.comment}".',
          type: "REPLY",
          read: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await createNotification(notification: notif, silent: true);
        UserModel? commentUser = await getUserInfo(id: comment.userId);
        if (commentUser != null) {
          String emailSubject =
              "[InFound] ${AuthenticationRepository.instance.currentUserModel.value!.userName} replied on your comment";
          String emailText =
              """Hi ${commentUser.userName}, ${AuthenticationRepository.instance.currentUserModel.value!.userName} replied on your coomment "${comment.comment}". ${AuthenticationRepository.instance.currentUserModel.value!.userName} replied: "${reply.comment}". You can view the reply by clicking this link: https://infound.web.app/post/${comment.postId}. Best regards, InFound Team""";
          String emailHtml = """
            <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
              <div style="margin:50px auto;width:70%;padding:20px 0">
                <div style="border-bottom:1px solid #eee">
                  <a href="https://infound.web.app" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
                    <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundFull.png?alt=media&token=cafd8ede-c425-48cc-8d7d-c07e8f3a661f" width="auto" height="50" alt="Icon">
                  </a>
                </div>
                <p style="font-size:1.1em">Hi ${commentUser.userName},</p>
                <p>${AuthenticationRepository.instance.currentUserModel.value!.userName} just replied on your comment "${comment.comment}".</p>
                <p style="margin: 0 0;margin-left: 24px; padding: 4px 0;line-height: 1.5;">${AuthenticationRepository.instance.currentUserModel.value!.userName} replied: "${reply.comment}".</p>
                <p>You can view the reply by clicking the link below:</p>
                <a href="https://infound.web.app/post/${comment.postId}" style="text-decoration: none;"><h2 style="background: #5BB6AE;width: max-content;padding: 0 16px;color: #fff;border-radius: 8px;font-size:18px;">Open InFound</h2></a>
                
                <p><br />Best regards,<br />InFound Team</p>
                <hr style="border:none;border-top:1px solid #eee" />
                <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
                  <a href="https://infound.web.app" style="float:left;padding:8px 16px;font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
                    <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundIcon.png?alt=media&token=c91d7209-08c2-4f3b-859b-424986f7ee47" width="auto" height="50" alt="Icon">
                  </a>
                  <div style="float:right;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
                    <p>InFound</p>
                    <p>Angeles City, Pampanga</p>
                    <p>Philippines</p>
                  </div>
                </div>
              </div>
            </div>""";
          createEmail(
              recipients: [commentUser.email],
              subject: emailSubject,
              text: emailText,
              html: emailHtml);
        }
      }

      AppPopups.successSnackBar(
          title: "InFound", message: "You replied to a comment.");
    }).catchError((err, stackTrace) {
      printDebug(err);
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to post reply. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createNotification(
      {required NotificationModel notification, bool silent = true}) async {
    await _db
        .collection("users")
        .doc(notification.userId)
        .collection("notifications")
        .doc(notification.notifId)
        .set(notification.toJson())
        .then((val) {
      if (!silent) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Notification has been sent.");
      }
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to send notification. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createEmail(
      {required List<String> recipients,
      required String subject,
      text,
      html}) async {
    String emailId = uuid.v1();
    Map<String, dynamic> emailData = {
      "to": recipients,
      "message": {
        "subject": subject,
        "text": text,
        "html": html,
      },
    };
    await _db
        .collection("mail")
        .doc(emailId)
        .set(emailData)
        .then((val) async {})
        .catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to create email. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createReport({required ReportModel report}) async {
    await _db
        .collection("reports")
        .doc(report.reportId)
        .set(report.toJson())
        .then((val) {
      AppPopups.successSnackBar(
          title: "Report has been sent",
          message: "Thank you for making InFound a better place.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to send report. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future<bool> checkUsernameAvailability({required String username}) async {
    final snapshot = await _db
        .collection("users")
        .where("userName", isEqualTo: username)
        .get();
    return snapshot.docs.length == 0;
  }

  Future<String?> checkUserRecordExist({required String email}) async {
    final snapshot =
        await _db.collection("users").where("email", isEqualTo: email).get();
    if (snapshot.docs.length == 0) {
      return null;
    } else {
      final userData = snapshot.docs
          .map(
            (doc) => UserModel.fromSnapshot(doc),
          )
          .single;
      return userData.uid;
    }
  }

  Future<UserModel?> getUserInfo(
      {required String id, bool byUsername = false}) async {
    final snapshot = await _db
        .collection("users")
        .where(byUsername ? "userName" : "uid", isEqualTo: id)
        .get();
    if (snapshot.docs.length == 0) {
      return null;
    } else {
      final userData = snapshot.docs
          .map(
            (doc) => UserModel.fromSnapshot(doc),
          )
          .single;
      return userData;
    }
  }

  Future<List<UserModel>> getAllUsers(
      {int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("users")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("users")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("users")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<UserModel> users =
        snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    return users;
  }

  Future<List<String>> getUsersWithQuery({required String query}) async {
    List<String> users = [];
    try {
      final snapshot = await _rd.ref("users").get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> usersMap =
            snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, value) {
          if (value['fullText'] != null) {
            String fullText = value['fullText'];
            if (fullText.contains(query)) {
              users.add(key);
            }
          }
        });
      }
    } catch (e) {
      printDebug(e);
    }
    return users;
  }

  Future<List<String>> getPostsWithQuery({required String query}) async {
    List<String> posts = [];
    try {
      final snapshot = await _rd.ref("posts").get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> postsMap =
            snapshot.value as Map<dynamic, dynamic>;
        postsMap.forEach((key, value) {
          if (value['fullText'] != null) {
            String fullText = value['fullText'].toString().toUpperCase();
            if (fullText.contains(query)) {
              posts.add(key);
            }
          }
        });
      }
    } catch (e) {
      printDebug(e);
    }
    return posts;
  }

  Future<Map<dynamic, dynamic>?> getPostsRD() async {
    try {
      final snapshot = await _rd.ref("posts").get();
      if (snapshot.exists) {
        return snapshot.value as Map<dynamic, dynamic>;
      }
    } catch (e) {
      printDebug(e);
    }
    return null;
  }

  Future<PostModel?> getSpecificPost(
      {required String postId,
      bool withComments = false,
      bool withSingleComment = false}) async {
    final snapshot =
        await _db.collection("posts").where("postId", isEqualTo: postId).get();
    if (snapshot.docs.length == 0) {
      return null;
    } else {
      final postData = snapshot.docs.map((doc) async {
        if (withComments) {
          final comments = await getAllCommentsByPost(postId: doc.id);
          return PostModel.fromSnapshot(doc, comments);
        } else if (withSingleComment) {
          final comments = await getSingleCommentByPost(postId: doc.id);
          return PostModel.fromSnapshot(doc, [comments]);
        }
        return PostModel.fromSnapshot(doc, []);
      }).single;
      return postData;
    }
  }

  Future<List<PostModel>> getAllPostsInList(
      {required List<String> postIds, int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("posts")
          .where("postId", whereIn: postIds)
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("posts")
            .where("postId", whereIn: postIds)
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("posts")
            .where("postId", whereIn: postIds)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    return snapshot.docs.map((doc) {
      return PostModel.fromSnapshot(doc, []);
    }).toList();
  }

  Future<List<PostModel>> getPostsOlderThan(
      {required DateTime date, int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("posts")
          .where("createdAt", isLessThan: date)
          .orderBy('createdAt', descending: false)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("posts")
            .where("createdAt", isLessThan: date)
            .orderBy('createdAt', descending: false)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("posts")
            .where("createdAt", isLessThan: date)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    return snapshot.docs.map((doc) {
      return PostModel.fromSnapshot(doc, []);
    }).toList();
  }

  Future<List<PostModel>> getAllPostsByUser({
    required String userId,
    bool withComments = false,
    bool withSingleComment = false,
    int? limit,
    DateTime? startAfter,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("posts")
          .where("userId", isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("posts")
            .where("userId", isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("posts")
            .where("userId", isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }

    List<Future<PostModel>> futurePosts = snapshot.docs.map((doc) async {
      if (withComments) {
        List<CommentModel> comments =
            await getAllCommentsByPost(postId: doc.id);
        return PostModel.fromSnapshot(doc, comments);
      } else if (withSingleComment) {
        CommentModel comments = await getSingleCommentByPost(postId: doc.id);
        return PostModel.fromSnapshot(doc, [comments]);
      }
      return PostModel.fromSnapshot(doc, []);
    }).toList();

    List<PostModel> posts = await Future.wait(futurePosts);

    return posts;
  }

  Future<List<PostModel>> getAllPosts({
    bool withComments = false,
    bool withSingleComment = false,
    int? limit,
    DateTime? startAfter,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("posts")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("posts")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("posts")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<Future<PostModel>> futurePosts = snapshot.docs.map((doc) async {
      if (withComments) {
        final comments = await getAllCommentsByPost(postId: doc.id);
        return PostModel.fromSnapshot(doc, comments);
      } else if (withSingleComment) {
        final comments = await getSingleCommentByPost(postId: doc.id);
        return PostModel.fromSnapshot(doc, [comments]);
      }
      return PostModel.fromSnapshot(doc, []);
    }).toList();

    List<PostModel> posts = await Future.wait(futurePosts);
    return posts;
  }

  Future<int> getNumPostsByUser({required String userId}) async {
    int cnt = 0;
    await _db
        .collection("posts")
        .where("userId", isEqualTo: userId)
        .count()
        .get()
        .then((val) {
      cnt = val.count ?? 0;
    });
    return cnt;
  }

  Future<CommentModel?> getCommentById(
      {required String postId, required String commentId}) async {
    final commentSnapshot = await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .get();
    final comment = CommentModel.fromSnapshot(commentSnapshot, []);
    return comment;
  }

  Future<CommentModel> getSingleCommentByPost(
      {required String postId, bool withReplies = false}) async {
    final commentsSnapshot = await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .orderBy('createdAt', descending: true)
        .get();
    final comment = commentsSnapshot.docs.map(
      (commentDoc) async {
        if (withReplies) {
          final replies = await getAllRepliesByComment(
              postId: postId, commentId: commentDoc.id);
          return CommentModel.fromSnapshot(commentDoc, replies);
        }
        return CommentModel.fromSnapshot(commentDoc, []);
      },
    ).single;
    return comment;
  }

  Future<List<CommentModel>> getAllCommentsByPost({
    required String postId,
    bool withReplies = false,
    int? limit = null,
    DateTime? startAfter = null,
  }) async {
    QuerySnapshot<Map<String, dynamic>> commentsSnapshot;
    if (limit == null) {
      commentsSnapshot = await _db
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        commentsSnapshot = await _db
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        commentsSnapshot = await _db
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    if (withReplies) {
      List<Future<CommentModel>> futureComments = commentsSnapshot.docs.map(
        (commentDoc) async {
          final replies = await getAllRepliesByComment(
              postId: postId, commentId: commentDoc.id);
          return CommentModel.fromSnapshot(commentDoc, replies);
        },
      ).toList();

      List<CommentModel> comments = await Future.wait(futureComments);
      return comments;
    }
    List<CommentModel> comments = commentsSnapshot.docs
        .map((commentDoc) => CommentModel.fromSnapshot(commentDoc, []))
        .toList();
    return comments;
  }

  Future<int> getNumCommentsByPost({required String postId}) async {
    int cnt = 0;
    await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .count()
        .get()
        .then((val) {
      cnt = val.count ?? 0;
    });
    return cnt;
  }

  Future<ReplyModel?> getReplyById(
      {required String postId,
      required String commentId,
      required String replyId}) async {
    final replySnapshot = await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .collection("replies")
        .doc(replyId)
        .get();
    final reply = ReplyModel.fromSnapshot(replySnapshot);
    return reply;
  }

  Future<int> getNumRepliesByComment(
      {required String postId, required String commentId}) async {
    int cnt = 0;
    await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .collection("replies")
        .count()
        .get()
        .then((val) {
      cnt = val.count ?? 0;
    });
    return cnt;
  }

  Future<List<ReplyModel>> getAllRepliesByComment({
    required String postId,
    required String commentId,
    int? limit,
    DateTime? startAfter,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("replies")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("replies")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    final replies = snapshot.docs
        .map(
          (doc) => ReplyModel.fromSnapshot(doc),
        )
        .toList();
    return replies;
  }

  Future getAllNotificationsByUser(
      {required String userId, int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("users")
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("users")
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("users")
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<NotificationModel> listNotifs = snapshot.docs
        .map((doc) => NotificationModel.fromSnapshot(doc))
        .toList();
    return listNotifs;
  }

  Future<ReplyModel?> getNotificationById(
      {required String userId, required String notifId}) async {
    final notifSnapshot = await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(notifId)
        .get();
    final notif = ReplyModel.fromSnapshot(notifSnapshot);
    return notif;
  }

  Future updateUser(
      {required UserModel user, bool silentUpdate = false}) async {
    await _db
        .collection("users")
        .doc(user.uid)
        .update(user.toJson())
        .then((val) async {
      await createUserRD(user: user);
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "User information has been updated.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update user. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future<int> getNumNotificationsByUser({required String userId}) async {
    int cnt = 0;

    await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .count()
        .get()
        .then((val) {
      cnt = val.count ?? 0;
    });
    return cnt;
  }

  Future<int> getNumUnreadNotificationsByUser({required String userId}) async {
    int cnt = 0;
    await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("read", isEqualTo: false)
        .count()
        .get()
        .then((val) {
      cnt = val.count ?? 0;
    });
    return cnt;
  }

  Future<List<ReportModel>> getActiveReports() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("status", isEqualTo: "ACTIVE")
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getResolvedReports() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("status", isEqualTo: "RESOLVED")
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getAllReports(
      {int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("reports")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("reports")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("reports")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getReportsByUser({required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("reporterId", isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getReportsConnectedToUser(
      {required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("reporterId", isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();

    QuerySnapshot<Map<String, dynamic>> snapshotTwo = await _db
        .collection("reports")
        .where("reporteeId", isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    reports.addAll(
        snapshotTwo.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList());
    return reports;
  }

  Future<List<ReportModel>> getReportsByPost({required String postId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("postId", isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getReportsByComment(
      {required String commentId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("commentId", isEqualTo: commentId)
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<ReportModel>> getReportsByReply({required String replyId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("reports")
        .where("replyId", isEqualTo: replyId)
        .orderBy('createdAt', descending: true)
        .get();
    List<ReportModel> reports =
        snapshot.docs.map((doc) => ReportModel.fromSnapshot(doc)).toList();
    return reports;
  }

  Future<List<BadgeModel>> getAllBadges(
      {int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("badges")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("badges")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("badges")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<BadgeModel> badges =
        snapshot.docs.map((doc) => BadgeModel.fromSnapshot(doc)).toList();
    return badges;
  }

  Future<BadgeModel?> getBadgeById({required String badgeId}) async {
    final badgeSnapshot = await _db.collection("badges").doc(badgeId).get();
    final badge = BadgeModel.fromSnapshot(badgeSnapshot);
    return badge;
  }

  Future updatePost(
      {required PostModel post, bool silentUpdate = false}) async {
    await _db
        .collection("posts")
        .doc(post.postId)
        .update(post.toJson())
        .then((val) async {
      createPostRD(post: post);
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Changes have been saved.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update post. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future updateComment(
      {required CommentModel comment, bool silentUpdate = false}) async {
    await _db
        .collection("posts")
        .doc(comment.postId)
        .collection("comments")
        .doc(comment.commentId)
        .update(comment.toJson())
        .then((val) {
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Changes have been saved.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update comment. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future updateReply(
      {required ReplyModel reply, bool silentUpdate = false}) async {
    await _db
        .collection("posts")
        .doc(reply.postId)
        .collection("comments")
        .doc(reply.commentId)
        .collection("replies")
        .doc(reply.replyId)
        .update(reply.toJson())
        .then((val) {
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Changes have been saved.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update reply. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future updateNotification(
      {required NotificationModel notif, bool silentUpdate = true}) async {
    await _db
        .collection("users")
        .doc(notif.userId)
        .collection("notifications")
        .doc(notif.notifId)
        .update(notif.toJson())
        .then((val) {
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Changes have been saved.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update notifications. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future updateReport(
      {required ReportModel report, bool silentUpdate = false}) async {
    await _db
        .collection("reports")
        .doc(report.reportId)
        .update(report.toJson())
        .then((val) {
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Changes have been saved.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update report. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future postLiked({required String postId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    if (currentUpvotes.isEmpty) {
      grantBadge(
          userId: AuthenticationRepository.instance.currentUserModel.value!.uid,
          badgeId: "126f4cc0-f2d3-11ef-9a40-e59eda3d52a5");
    }
    currentUpvotes.add(postId);
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    PostModel? post = await getSpecificPost(postId: postId);
    PostModel updatedPost = post!.copyWith(numUpvotes: post.numUpvotes + 1);
    await updatePost(post: updatedPost, silentUpdate: true);

    if (post.userId !=
        AuthenticationRepository.instance.currentUserModel.value!.uid) {
      NotificationModel notif = NotificationModel(
        notifId: uuid.v1(),
        userId: post.userId,
        senderUsername:
            AuthenticationRepository.instance.currentUserModel.value!.userName,
        senderUid:
            AuthenticationRepository.instance.currentUserModel.value!.uid,
        targetId: postId,
        postId: postId,
        notifContent: 'liked your post "${post.title}".',
        type: "LIKE",
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createNotification(notification: notif, silent: true);
    }
  }

  Future postUnliked({required String postId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    currentUpvotes.remove(postId);
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    PostModel? post = await getSpecificPost(postId: postId);
    PostModel updatedPost = post!.copyWith(numUpvotes: post.numUpvotes - 1);
    await updatePost(post: updatedPost, silentUpdate: true);
  }

  Future postBookmarked({required String postId}) async {
    List<String> currentBookmarks =
        AuthenticationRepository.instance.currentUserModel.value!.bookmarks;
    currentBookmarks.add(postId);
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(bookmarks: currentBookmarks, updatedAt: DateTime.now());
    AuthenticationRepository.instance.currentUserModel.value = user;
    await updateUser(user: user, silentUpdate: true);
  }

  Future postUnbookmarked({required String postId}) async {
    List<String> currentBookmarks =
        AuthenticationRepository.instance.currentUserModel.value!.bookmarks;
    currentBookmarks.remove(postId);
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(bookmarks: currentBookmarks, updatedAt: DateTime.now());
    AuthenticationRepository.instance.currentUserModel.value = user;
    await updateUser(user: user, silentUpdate: true);
  }

  Future commentLiked(
      {required String postId, required String commentId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    currentUpvotes
        .add("${postId}${AppConstants.tCommentSeparator}${commentId}");
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    CommentModel? comment =
        await getCommentById(postId: postId, commentId: commentId);
    CommentModel updatedComment =
        comment!.copyWith(numUpvotes: comment.numUpvotes + 1);
    await updateComment(comment: updatedComment, silentUpdate: true);

    if (comment.userId !=
        AuthenticationRepository.instance.currentUserModel.value!.uid) {
      NotificationModel notif = NotificationModel(
        notifId: uuid.v1(),
        userId: comment.userId,
        senderUid:
            AuthenticationRepository.instance.currentUserModel.value!.uid,
        senderUsername:
            AuthenticationRepository.instance.currentUserModel.value!.userName,
        targetId: commentId,
        postId: postId,
        notifContent: 'liked your comment "${comment.comment}".',
        type: "LIKE",
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createNotification(notification: notif, silent: true);
    }
  }

  Future commentUnliked(
      {required String postId, required String commentId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    currentUpvotes
        .remove("${postId}${AppConstants.tCommentSeparator}${commentId}");
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    CommentModel? comment =
        await getCommentById(postId: postId, commentId: commentId);
    CommentModel updatedComment =
        comment!.copyWith(numUpvotes: comment.numUpvotes - 1);
    await updateComment(comment: updatedComment, silentUpdate: true);
  }

  Future replyLiked(
      {required String postId,
      required String commentId,
      required String replyId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    currentUpvotes.add(
        "${postId}${AppConstants.tCommentSeparator}${commentId}${AppConstants.tReplySeparator}${replyId}");
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    ReplyModel? reply = await getReplyById(
        postId: postId, commentId: commentId, replyId: replyId);
    ReplyModel updatedReply = reply!.copyWith(numUpvotes: reply.numUpvotes + 1);
    await updateReply(reply: updatedReply, silentUpdate: true);

    if (reply.userId !=
        AuthenticationRepository.instance.currentUserModel.value!.uid) {
      NotificationModel notif = NotificationModel(
        notifId: uuid.v1(),
        userId: reply.userId,
        senderUid:
            AuthenticationRepository.instance.currentUserModel.value!.uid,
        senderUsername:
            AuthenticationRepository.instance.currentUserModel.value!.userName,
        targetId: replyId,
        postId: postId,
        notifContent: 'liked your reply "${reply.comment}".',
        type: "LIKE",
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createNotification(notification: notif, silent: true);
    }
  }

  Future replyUnliked(
      {required String postId,
      required String commentId,
      required String replyId}) async {
    List<String> currentUpvotes =
        AuthenticationRepository.instance.currentUserModel.value!.upvotes;
    currentUpvotes
        .remove("${postId}${AppConstants.tCommentSeparator}${commentId}");
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(upvotes: currentUpvotes, updatedAt: DateTime.now());
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;

    ReplyModel? reply = await getReplyById(
        postId: postId, commentId: commentId, replyId: replyId);
    ReplyModel updatedReply = reply!.copyWith(numUpvotes: reply.numUpvotes - 1);
    await updateReply(reply: updatedReply, silentUpdate: true);
  }

  Future markNotificationAsRead({required NotificationModel notif}) async {
    await updateNotification(
        notif: notif.copyWith(read: true), silentUpdate: true);
  }

  Future markAllNotificationsAsRead({required String userId}) async {
    final snapshot = await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .get();
    List<NotificationModel> notifs = snapshot.docs
        .map((doc) => NotificationModel.fromSnapshot(doc))
        .toList();
    for (NotificationModel notif in notifs) {
      await updateNotification(
          notif: notif.copyWith(read: true), silentUpdate: true);
    }
  }

  Future markAllNotificationsAsUnread({required String userId}) async {
    final snapshot = await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .get();
    List<NotificationModel> notifs = snapshot.docs
        .map((doc) => NotificationModel.fromSnapshot(doc))
        .toList();
    for (NotificationModel notif in notifs) {
      await updateNotification(
          notif: notif.copyWith(read: false), silentUpdate: true);
    }
  }

  Future markReportAsResolved({required ReportModel report}) async {
    await updateReport(
        report: report.copyWith(status: "RESOLVED"), silentUpdate: true);
  }

  Future markReportAsActive({required ReportModel report}) async {
    await updateReport(
        report: report.copyWith(status: "ACTIVE"), silentUpdate: true);
  }

  Future markReportAsIgnored({required ReportModel report}) async {
    await updateReport(
        report: report.copyWith(status: "IGNORED"), silentUpdate: true);
  }

  Future clearNotifications({required String userId}) async {
    final snapshot = await _db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .get();
    List<NotificationModel> notifs = snapshot.docs
        .map((doc) => NotificationModel.fromSnapshot(doc))
        .toList();
    for (NotificationModel notif in notifs) {
      await _db
          .collection("users")
          .doc(userId)
          .collection("notifications")
          .doc(notif.notifId)
          .delete();
    }
  }

  Future clearBookmarks({required String userId}) async {
    UserModel? user = AuthenticationRepository.instance.currentUserModel.value!
        .copyWith(bookmarks: []);
    await updateUser(user: user, silentUpdate: true);
    AuthenticationRepository.instance.currentUserModel.value = user;
  }

  Future deletePostById(
      {required String postId,
      required String userId,
      bool silentDelete = false}) async {
    List<ReportModel> reports = await getReportsByPost(postId: postId);
    for (ReportModel report in reports) {
      await _db.collection("reports").doc(report.reportId).delete();
    }
    List<CommentModel> comments = await getAllCommentsByPost(postId: postId);
    for (CommentModel comment in comments) {
      List<ReplyModel> replies = await getAllRepliesByComment(
          postId: postId, commentId: comment.commentId);
      for (ReplyModel reply in replies) {
        await _db
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(comment.commentId)
            .collection("replies")
            .doc(reply.replyId)
            .delete();
      }
      await _db
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(comment.commentId)
          .delete();
    }
    await _db.collection("posts").doc(postId).delete().then((_) async {
      final rdSnapshot = await _rd.ref("posts/${postId}").get();
      if (rdSnapshot.exists) {
        await _rd.ref("posts/${postId}").remove();
      }
      UserModel? user = await getUserInfo(id: userId);
      if (user != null) {
        List<String> currentPosts = user.posts;
        currentPosts.remove(postId);
        UserModel? newUser =
            user.copyWith(posts: currentPosts, updatedAt: DateTime.now());
        updateUser(user: user, silentUpdate: true);
        if (newUser.uid ==
            AuthenticationRepository.instance.currentUserModel.value!.uid) {
          AuthenticationRepository.instance.currentUserModel.value = newUser;
        }
      }
      if (!silentDelete) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Post has been deleted.");
      }
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete post. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future deleteCommentById(
      {required String postId,
      required String commentId,
      required String userId,
      bool silentDelete = false}) async {
    List<ReportModel> reports = await getReportsByComment(commentId: commentId);
    for (ReportModel report in reports) {
      await _db.collection("reports").doc(report.reportId).delete();
    }
    List<ReplyModel> replies =
        await getAllRepliesByComment(postId: postId, commentId: commentId);
    for (ReplyModel reply in replies) {
      await _db
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(reply.replyId)
          .delete();
    }
    await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .delete()
        .then((_) async {
      //update user's comments list
      UserModel? user = await getUserInfo(id: userId);
      if (user != null) {
        List<String> currentComments = user.comments;
        currentComments
            .remove('${postId}${AppConstants.tCommentSeparator}${commentId}');
        UserModel? newUser =
            user.copyWith(comments: currentComments, updatedAt: DateTime.now());
        updateUser(user: user, silentUpdate: true);
        if (newUser.uid ==
            AuthenticationRepository.instance.currentUserModel.value!.uid) {
          AuthenticationRepository.instance.currentUserModel.value = newUser;
        }
      }

      //update post's numComments and commentsId
      PostModel? post = await getSpecificPost(postId: postId);
      List<String> currentCommentsId = post!.commentsId;
      currentCommentsId.remove(commentId);
      PostModel updatedPost = post.copyWith(
          numComments: currentCommentsId.length, commentsId: currentCommentsId);
      await updatePost(post: updatedPost, silentUpdate: true);

      if (!silentDelete) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Comment has been deleted.");
      }
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete comment. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future deleteReplyById(
      {required String postId,
      required String commentId,
      required String userId,
      required String replyId,
      bool silent = false}) async {
    List<ReportModel> reports = await getReportsByReply(replyId: replyId);
    for (ReportModel report in reports) {
      await _db.collection("reports").doc(report.reportId).delete();
    }
    await _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .collection("replies")
        .doc(replyId)
        .delete()
        .then((_) async {
      //update user's replies list
      UserModel? user = await getUserInfo(id: userId);
      if (user != null) {
        List<String> currentReplies = user.replies;
        currentReplies.remove(
            '${postId}${AppConstants.tCommentSeparator}${commentId}${AppConstants.tReplySeparator}${replyId}');
        UserModel? newUser =
            user.copyWith(replies: currentReplies, updatedAt: DateTime.now());
        updateUser(user: user, silentUpdate: true);
        if (newUser.uid ==
            AuthenticationRepository.instance.currentUserModel.value!.uid) {
          AuthenticationRepository.instance.currentUserModel.value = newUser;
        }
      }

      //update comment's numReplies
      CommentModel? comment =
          await getCommentById(postId: postId, commentId: commentId);
      List<String> currentRepliesId = comment!.repliesId;
      currentRepliesId.remove(replyId);
      CommentModel updatedComment =
          comment.copyWith(repliesId: currentRepliesId);
      await updateComment(comment: updatedComment, silentUpdate: true);
      if (!silent) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Reply has been deleted.");
      }
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete reply. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future deleteReportById(
      {required String reportId, bool silent = false}) async {
    await _db.collection("reports").doc(reportId).delete().then((_) {
      if (!silent) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Report has been deleted.");
      }
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete report. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future deleteAllUserData({required userId}) async {
    final snapshot = await _db.collection("users").doc(userId).get();
    if (snapshot.exists) {
      try {
        UserModel user = UserModel.fromSnapshot(snapshot);
        List<String> posts = user.posts;
        List<String> comments = user.comments;
        List<String> replies = user.replies;

        for (String replyId in replies) {
          List<String> commentData =
              replyId.split(AppConstants.tCommentSeparator);
          List<String> replyData =
              commentData[1].split(AppConstants.tReplySeparator);

          await deleteReplyById(
            postId: commentData[0],
            commentId: replyData[0],
            userId: userId,
            replyId: replyData[1],
            silent: true,
          );
        }
        for (String commentId in comments) {
          List<String> commentData =
              commentId.split(AppConstants.tCommentSeparator);
          await deleteCommentById(
            postId: commentData[0],
            commentId: commentData[1],
            userId: userId,
            silentDelete: true,
          );
        }
        for (String postId in posts) {
          await deletePostById(
              postId: postId, userId: userId, silentDelete: true);
        }
        List<NotificationModel> notifs =
            await getAllNotificationsByUser(userId: userId);
        for (NotificationModel notif in notifs) {
          await _db
              .collection("users")
              .doc(userId)
              .collection("notifications")
              .doc(notif.notifId)
              .delete();
        }
        List<ReportModel> reports =
            await getReportsConnectedToUser(userId: userId);
        for (ReportModel report in reports) {
          await deleteReportById(reportId: report.reportId, silent: true);
        }
        List<UserRequestModel> requests =
            await getRequestsByUser(userId: userId);
        for (UserRequestModel request in requests) {
          await deleteRequestById(requestId: request.requestId);
        }
        await _db.collection("users").doc(userId).delete().then((_) async {
          final rdSnapshot = await _rd.ref("users/${userId}").get();
          if (rdSnapshot.exists) {
            await _rd.ref("users/${userId}").remove();
          }
          AppPopups.successSnackBar(
              title: "InFound", message: "User data has been deleted.");
        }).catchError((err, stackTrace) {
          AppPopups.errorSnackBar(
              title: "[DATABASE] Error",
              message: "Unable to delete user data. Please try again later.");
          printDebug(err.toString());
        });
      } catch (e) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to delete user data. Please try again later.");
        printDebug(e.toString());
      }
    }
  }

  Future getAllUserRequests({int? limit, DateTime? startAfter}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (limit == null) {
      snapshot = await _db
          .collection("requests")
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      if (startAfter != null) {
        snapshot = await _db
            .collection("requests")
            .orderBy('createdAt', descending: true)
            .startAfter([startAfter])
            .limit(limit)
            .get();
      } else {
        snapshot = await _db
            .collection("requests")
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
      }
    }
    List<UserRequestModel> requests =
        snapshot.docs.map((doc) => UserRequestModel.fromSnapshot(doc)).toList();
    return requests;
  }

  Future approveUserRequest({required UserRequestModel request}) async {
    UserModel? userInfo = await getUserInfo(id: request.uid);
    if (userInfo != null) {
      if (request.type == "ADMIN") {
        UserModel user =
            userInfo.copyWith(isAdmin: true, updatedAt: DateTime.now());
        await updateUser(user: user, silentUpdate: true);
      }
      if (request.type == "VERIFIED") {
        UserModel user =
            userInfo.copyWith(isVerified: true, updatedAt: DateTime.now());
        await updateUser(user: user, silentUpdate: true);
      }
      NotificationModel notif = NotificationModel(
        notifId: uuid.v1(),
        userId: request.uid,
        senderUid:
            AuthenticationRepository.instance.currentUserModel.value!.uid,
        senderUsername: "An admin",
        targetId: request.uid,
        postId: "",
        notifContent:
            'approved your ${request.type == 'ADMIN' ? 'admin access' : 'verified account'} request.',
        type: "USERREQUEST",
        read: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await createNotification(notification: notif, silent: true);
      await deleteRequestById(requestId: request.requestId);
    } else {
      AppPopups.errorSnackBar(
          title: 'Unknown user', message: 'User is not found in the database.');
    }
  }

  Future declineUserRequest({required UserRequestModel request}) async {
    NotificationModel notif = NotificationModel(
      notifId: uuid.v1(),
      userId: request.uid,
      senderUid: AuthenticationRepository.instance.currentUserModel.value!.uid,
      senderUsername: "An admin",
      targetId: request.uid,
      postId: "",
      notifContent:
          'declined your ${request.type == 'ADMIN' ? 'admin access' : 'verified account'} request.',
      type: "USERREQUEST",
      read: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await createNotification(notification: notif, silent: true);
    await deleteRequestById(requestId: request.requestId);
  }

  Future createUserRequest({required UserRequestModel request}) async {
    await _db
        .collection("requests")
        .doc(request.requestId)
        .set(request.toJson())
        .then((_) {
      AppPopups.successSnackBar(
          title: "InFound", message: "Request has been sent.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to send request. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future<bool> checkIfRequestExists(
      {required String uid, required String type}) async {
    final snapshot = await _db
        .collection("requests")
        .where("uid", isEqualTo: uid)
        .where("type", isEqualTo: type)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future deleteRequestById({required String requestId}) async {
    await _db
        .collection("requests")
        .doc(requestId)
        .delete()
        .then((_) {})
        .catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete request. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future createBadge({required BadgeModel badge}) async {
    await _db
        .collection("badges")
        .doc(badge.badgeId)
        .set(badge.toJson())
        .then((_) {
      AppPopups.successSnackBar(
          title: "InFound", message: "Badge has been created.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to create badge. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future updateBadge(
      {required BadgeModel badge, bool silentUpdate = false}) async {
    await _db
        .collection("badges")
        .doc(badge.badgeId)
        .update(badge.toJson())
        .then((val) {
      if (!silentUpdate) {
        AppPopups.successSnackBar(
            title: "InFound", message: "Badge information has been updated.");
      }
    }).catchError((err, stackTrace) {
      if (!silentUpdate) {
        AppPopups.errorSnackBar(
            title: "[DATABASE] Error",
            message: "Unable to update badge. Please try again later.");
      }
      printDebug(err.toString());
    });
  }

  Future getBadgeInfo({required String badgeId}) async {
    final snapshot = await _db.collection("badges").doc(badgeId).get();
    return BadgeModel.fromSnapshot(snapshot);
  }

  Future grantBadge({required String userId, required String badgeId}) async {
    BadgeModel? badge = await getBadgeInfo(badgeId: badgeId);
    UserModel? user = await getUserInfo(id: userId);
    if (user != null && badge != null) {
      List<String> currentBadges = user.badges;
      if (!currentBadges.contains(badgeId)) {
        currentBadges.add(badgeId);
      }
      UserModel? newUser =
          user.copyWith(badges: currentBadges, updatedAt: DateTime.now());
      await updateUser(user: newUser, silentUpdate: true).then((_) {
        NotificationModel notif = NotificationModel(
          notifId: uuid.v1(),
          userId: userId,
          senderUid: userId,
          senderUsername: "",
          targetId: badgeId,
          postId: "",
          notifContent: 'You just earned "${badge!.badgeTitle}" badge.',
          type: "BADGE",
          read: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        createNotification(notification: notif, silent: true);
        List<String> currentBadgeOwners = badge.badgeOwners;
        if (!currentBadgeOwners.contains(userId)) {
          currentBadgeOwners.add(userId);
        }
        updateBadge(
            badge: badge.copyWith(badgeOwners: currentBadgeOwners),
            silentUpdate: true);
      });
      if (newUser.uid ==
          AuthenticationRepository.instance.currentUserModel.value!.uid) {
        AuthenticationRepository.instance.currentUserModel.value = newUser;
      }
    }
  }

  Future revokeBadge({required String userId, required String badgeId}) async {
    BadgeModel? badge = await getBadgeInfo(badgeId: badgeId);
    UserModel? user = await getUserInfo(id: userId);
    if (user != null && badge != null) {
      List<String> currentBadges = user.badges;
      if (currentBadges.contains(badgeId)) {
        currentBadges.remove(badgeId);
      }
      UserModel? newUser =
          user.copyWith(badges: currentBadges, updatedAt: DateTime.now());
      await updateUser(user: newUser, silentUpdate: true).then((_) {
        List<String> currentBadgeOwners = badge.badgeOwners;
        if (currentBadgeOwners.contains(userId)) {
          currentBadgeOwners.remove(userId);
        }
        updateBadge(
            badge: badge.copyWith(badgeOwners: currentBadgeOwners),
            silentUpdate: true);
      });
      if (newUser.uid ==
          AuthenticationRepository.instance.currentUserModel.value!.uid) {
        AuthenticationRepository.instance.currentUserModel.value = newUser;
      }
    }
  }

  Future deleteBadgeById({required String badgeId}) async {
    await _db.collection("badges").doc(badgeId).delete().then((_) async {
      List<UserModel> users = await getUsersWithBadgeId(badgeId: badgeId);
      for (UserModel user in users) {
        List<String> currentBadges = user.badges;
        if (currentBadges.contains(badgeId)) {
          currentBadges.remove(badgeId);
        }
        UserModel? newUser =
            user.copyWith(badges: currentBadges, updatedAt: DateTime.now());
        await updateUser(user: newUser, silentUpdate: true);
        if (newUser.uid ==
            AuthenticationRepository.instance.currentUserModel.value!.uid) {
          AuthenticationRepository.instance.currentUserModel.value = newUser;
        }
      }
      AppPopups.successSnackBar(
          title: "InFound", message: "Badge has been deleted.");
    }).catchError((err, stackTrace) {
      AppPopups.errorSnackBar(
          title: "[DATABASE] Error",
          message: "Unable to delete badge. Please try again later.");
      printDebug(err.toString());
    });
  }

  Future getUsersWithBadgeId({required String badgeId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection("users")
        .where("badges", arrayContains: badgeId)
        .get();
    List<UserModel> users =
        snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    return users;
  }

  Future getRequestsByUser({required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("requests").where("uid", isEqualTo: userId).get();
    List<UserRequestModel> requests =
        snapshot.docs.map((doc) => UserRequestModel.fromSnapshot(doc)).toList();
    return requests;
  }

  Future userSearch({required String query}) async {
    List<String> users =
        await DatabaseRepository.instance.getUsersWithQuery(query: query);
    List<UserModel> userModels = [];
    for (String user in users) {
      UserModel? userModel = await getUserInfo(id: user);
      if (userModel != null) {
        userModels.add(userModel);
      }
    }
    return userModels;
  }

  Future sendOTP({required String email, username, otp}) async {
    List<String> recipients = [email];
    String subject = "[InFound] OTP Verification for Account Deletion";
    String emailText =
        """Hi ${username}, We're sad to see you go. It truly saddens us to process your request for account and data deletion, but we respect your decision. To ensure the security of your request, please use the following One-Time Password (OTP) to confirm your identity: ${otp}. This OTP is valid for 5 minutes. Please enter it in the required field to proceed with the deletion process. If you did not request this deletion or have changed your mind, please disregard this email—your account and data will remain safe with us. If there’s anything we could have done better or if you ever decide to return, we'd love to welcome you back. Feel free to reach out to our support team at infoundmain@gmail.com. Wishing you all the best, InFound Team""";
    String emailHtml =
        """<div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
  <div style="margin:50px auto;width:70%;padding:20px 0">
    <div style="border-bottom:1px solid #eee">
      <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
        <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundFull.png?alt=media&token=cafd8ede-c425-48cc-8d7d-c07e8f3a661f" width="auto" height="50" alt="Icon">
      </a>
    </div>
    <p style="font-size:1.1em">Hi ${username},</p>
    <p>We're sad to see you go. It truly saddens us to process your request for account and data deletion, but we respect your decision.

To ensure the security of your request, please use the following One-Time Password (OTP) to confirm your identity:</p>
    <h2 style="background: #5BB6AE;margin: 0 auto;width: max-content;padding: 0 16px;color: #fff;border-radius: 8px;font-size:32px;">${otp}</h2>
    <p>This OTP is valid for 5 minutes. Please enter it in the required field to proceed with the deletion process.</p>

<p>If you did not request this deletion or have changed your mind, please disregard this email—your account and data will remain safe with us.</p>

<p>If there's anything we could have done better or if you ever decide to return, we'd love to welcome you back. Feel free to reach out to our support team at <a href="infoundmain@gmail.com"><span>infoundmain@gmail.com</span></a></p>
    <p><br />Wishing you all the best,<br />InFound Team</p>
    <hr style="border:none;border-top:1px solid #eee" />
    <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
      <a href="" style="float:left;padding:8px 16px;font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">
        <img src="https://firebasestorage.googleapis.com/v0/b/infound.firebasestorage.app/o/icons%2FInFoundIcon.png?alt=media&token=c91d7209-08c2-4f3b-859b-424986f7ee47" width="auto" height="50" alt="Icon">
      </a>
      <div style="float:right;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
        <p>InFound</p>
        <p>Angeles City, Pampanga</p>
        <p>Philippines</p>
      </div>
    </div>
  </div>
</div>""";
    await createEmail(
        recipients: recipients,
        subject: subject,
        text: emailText,
        html: emailHtml);
  }
}
