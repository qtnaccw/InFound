import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/comment_container.dart';
import 'package:infound/components/containers/post_container.dart';
import 'package:infound/components/containers/reply_container.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/models/comment_model.dart';
import 'package:infound/models/notification_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/reply_model.dart';
import 'package:infound/models/report_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostProvider extends StatefulWidget {
  const PostProvider(
      {super.key,
      required this.post,
      this.nullWidget,
      this.expanded = false,
      this.withComments = false,
      this.onBookmarkCallback,
      this.onDelete,
      this.isPreview = false});

  final PostModel post;
  final Widget? nullWidget;
  final bool expanded;
  final bool withComments;
  final Function(bool, String)? onBookmarkCallback;
  final Function(String)? onDelete;
  final bool isPreview;

  @override
  State<PostProvider> createState() => _PostProviderState();
}

class _PostProviderState extends State<PostProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on post. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.post.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? PostContainer(
                key: ValueKey(widget.post.postId),
                postId: widget.post.postId,
                uid: widget.post.userId,
                username: userModel!.userName,
                userProfileURL: userModel!.profileURL,
                isVerified: userModel!.isVerified,
                timestamp: timeago.format(widget.post.createdAt),
                type: widget.post.type,
                title: widget.post.title,
                description: widget.post.description,
                location: widget.post.location,
                itemColor: widget.post.itemColor,
                itemBrand: widget.post.itemBrand,
                itemSize: widget.post.itemSize,
                images: widget.post.imagesURL,
                numUpvotes: widget.post.numUpvotes,
                numComments: widget.post.numComments,
                isLiked:
                    AuthenticationRepository.instance.currentUserModel.value ==
                            null
                        ? false
                        : AuthenticationRepository
                            .instance.currentUserModel.value!.upvotes
                            .contains(widget.post.postId),
                isBookmarked:
                    AuthenticationRepository.instance.currentUserModel.value ==
                            null
                        ? false
                        : AuthenticationRepository
                            .instance.currentUserModel.value!.bookmarks
                            .contains(widget.post.postId),
                expanded: widget.expanded,
                withComments: widget.withComments,
                onBookmarkCallback: widget.onBookmarkCallback,
                onDelete: widget.onDelete,
                onChangeType: (type) async {
                  await DatabaseRepository.instance
                      .updatePost(post: widget.post.copyWith(type: type));
                },
                isPreview: widget.isPreview,
                postModel: widget.post,
              )
            : widget.nullWidget ?? Container()
        : ReportContainerShimmer();
  }
}

class CommentProvider extends StatefulWidget {
  const CommentProvider(
      {super.key,
      required this.comment,
      this.nullWidget,
      this.lastItem,
      this.onDelete,
      this.isPreview = false});

  final CommentModel comment;
  final Widget? nullWidget;
  final bool? lastItem;
  final Function(String)? onDelete;
  final bool isPreview;

  @override
  State<CommentProvider> createState() => _CommentProviderState();
}

class _CommentProviderState extends State<CommentProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on comment. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.comment.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? CommentContainer(
                key: ValueKey(widget.comment.postId + widget.comment.commentId),
                userId: widget.comment.userId,
                postId: widget.comment.postId,
                commentId: widget.comment.commentId,
                userProfileURL: userModel!.profileURL,
                username: userModel!.userName,
                timestamp: timeago.format(widget.comment.createdAt),
                numUpvotes: widget.comment.numUpvotes,
                content: widget.comment.comment,
                isLiked: AuthenticationRepository
                            .instance.currentUserModel.value ==
                        null
                    ? false
                    : AuthenticationRepository
                        .instance.currentUserModel.value!.upvotes
                        .contains(
                            "${widget.comment.postId}${AppConstants.tCommentSeparator}${widget.comment.commentId}"),
                image: widget.comment.image,
                replyCount: widget.comment.repliesId.length,
                lastItem: widget.lastItem,
                onDelete: widget.onDelete,
                isPreview: widget.isPreview,
                isVerified: userModel!.isVerified,
              )
            : widget.nullWidget ?? Container()
        : CommentWidgetContainerShimmer();
  }
}

class ReplyProvider extends StatefulWidget {
  const ReplyProvider(
      {super.key,
      required this.reply,
      this.nullWidget,
      required this.onReplyTap,
      this.lastItem,
      this.onDelete,
      this.isPreview = false});

  final ReplyModel reply;
  final Widget? nullWidget;
  final void Function(String, String, String, String, String) onReplyTap;
  final bool? lastItem;
  final Function(String)? onDelete;
  final bool isPreview;

  @override
  State<ReplyProvider> createState() => _ReplyProviderState();
}

class _ReplyProviderState extends State<ReplyProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on reply. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.reply.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? ReplyContainer(
                key: ValueKey(widget.reply.postId +
                    widget.reply.commentId +
                    widget.reply.replyId),
                userId: widget.reply.userId,
                postId: widget.reply.postId,
                commentId: widget.reply.commentId,
                replyId: widget.reply.replyId,
                content: widget.reply.comment,
                userProfileURL: userModel!.profileURL,
                username: userModel!.userName,
                timestamp: timeago.format(widget.reply.createdAt),
                image: widget.reply.image,
                isLiked: AuthenticationRepository
                            .instance.currentUserModel.value ==
                        null
                    ? false
                    : AuthenticationRepository
                        .instance.currentUserModel.value!.upvotes
                        .contains(
                            "${widget.reply.postId}${AppConstants.tCommentSeparator}${widget.reply.commentId}${AppConstants.tReplySeparator}${widget.reply.replyId}"),
                numUpVotes: widget.reply.numUpvotes,
                onReplyTap: () {
                  widget.onReplyTap(
                      userModel!.userName,
                      widget.reply.userId,
                      widget.reply.postId,
                      widget.reply.commentId,
                      widget.reply.replyId);
                },
                onLikeTap: () {},
                lastItem: widget.lastItem,
                onDelete: widget.onDelete,
                isPreview: widget.isPreview,
                isVerified: userModel!.isVerified,
              )
            : widget.nullWidget ?? Container()
        : ReplyWidgetContainerShimmer();
  }
}

class NotificationProvider extends StatefulWidget {
  const NotificationProvider(
      {super.key,
      required this.notification,
      this.nullWidget,
      required this.onClick});

  final NotificationModel notification;
  final Widget? nullWidget;
  final Function() onClick;

  @override
  State<NotificationProvider> createState() => _NotificationProviderState();
}

class _NotificationProviderState extends State<NotificationProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on notification. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.notification.senderUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? NotificationContainer(
                key: ValueKey(widget.notification.notifId),
                notifId: widget.notification.notifId,
                userId: widget.notification.userId,
                senderUsername: widget.notification.senderUsername,
                content: widget.notification.notifContent,
                senderUid: widget.notification.senderUid,
                senderProfileUrl: userModel!.profileURL,
                timestamp: timeago.format(widget.notification.createdAt),
                type: widget.notification.type,
                postID: widget.notification.postId,
                targetID: widget.notification.targetId,
                read: widget.notification.read,
                onClick: () async {
                  widget.onClick();
                })
            : widget.nullWidget ?? Container()
        : NotificationContainerShimmer();
  }
}

class ReportProvider extends StatefulWidget {
  const ReportProvider(
      {super.key, required this.report, this.nullWidget, this.onDelete});

  final ReportModel report;
  final Widget? nullWidget;
  final Function(String)? onDelete;

  @override
  State<ReportProvider> createState() => _ReportProviderState();
}

class _ReportProviderState extends State<ReportProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on report. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.report.reporterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? ReportContainer(
                key: ValueKey(widget.report.reportId),
                report: widget.report,
                user: userModel!,
                onDelete: widget.onDelete,
              )
            : widget.nullWidget ?? Container()
        : ReportContainerShimmer();
  }
}

class UserRequestProvider extends StatefulWidget {
  const UserRequestProvider(
      {super.key,
      required this.userRequest,
      this.nullWidget,
      this.onApprove,
      this.onDecline});

  final UserRequestModel userRequest;
  final Widget? nullWidget;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  @override
  State<UserRequestProvider> createState() => _UserRequestProviderState();
}

class _UserRequestProviderState extends State<UserRequestProvider> {
  UserModel? userModel;
  bool fetchDone = false;

  Future getUserInfo(String uid) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? userModelTemp =
          await DatabaseRepository.instance.getUserInfo(id: uid);
      if (mounted) {
        setState(() {
          userModel = userModelTemp;
          fetchDone = true;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting user information on user request. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getUserInfo(widget.userRequest.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetchDone
        ? userModel != null
            ? UserRequestContainer(
                key: ValueKey(widget.userRequest.requestId),
                timestamp: timeago.format(widget.userRequest.createdAt),
                userRequest: widget.userRequest,
                user: userModel!,
                onApprove: widget.onApprove,
                onDecline: widget.onDecline,
              )
            : widget.nullWidget ?? Container()
        : UserRequestContainerShimmer();
  }
}

void printDebug(dynamic message) {
  // if (kDebugMode) {
  //   print(message);
  // }
}
