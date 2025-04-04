import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infound/components/containers/comment_reply_compose_container.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/main.dart';
import 'package:infound/models/reply_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/repos/storage_repository.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

import 'package:readmore/readmore.dart';

class CommentContainer extends StatefulWidget {
  const CommentContainer(
      {super.key,
      required this.userId,
      required this.postId,
      required this.commentId,
      required this.userProfileURL,
      required this.username,
      required this.timestamp,
      required this.numUpvotes,
      required this.content,
      this.image,
      required this.isLiked,
      required this.replyCount,
      this.lastItem = false,
      this.onDelete,
      this.isPreview = false,
      required this.isVerified});

  final String userId;
  final String postId;
  final String commentId;
  final String userProfileURL;
  final String username;
  final bool isVerified;
  final String timestamp;
  final String content;
  final String? image;
  final int numUpvotes;
  final bool isLiked;
  final int replyCount;
  final bool? lastItem;
  final Function(String)? onDelete;
  final bool isPreview;

  @override
  State<CommentContainer> createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  bool isReplying = false;
  bool isReplyingToComment = true;
  late TextEditingController replyController;
  Uint8List? image = null;
  XFile? imageXFile = null;
  bool isLikedObs = false;
  int numUpvotesObs = 0;
  String replyingTo = '';
  String replyingToId = '';
  List<ReplyModel> repliesListObs = <ReplyModel>[];
  bool repliesHasNext = true;
  bool isFetchingReplies = false;
  bool isPerformingLike = false;
  bool repliesVisible = true;
  int numReplies = 0;

  Future getReplies({DateTime? startAfter, int? limit}) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      List<ReplyModel> temp = await DatabaseRepository.instance
          .getAllRepliesByComment(
              postId: widget.postId,
              commentId: widget.commentId,
              limit: limit ?? AppConstants.nLimitReplies,
              startAfter: startAfter);
      if (mounted)
        setState(() {
          if (temp.length < (limit ?? AppConstants.nLimitReplies) ||
              temp.length == 0) repliesHasNext = false;
          repliesListObs.addAll(temp);
        });
    } catch (e) {
      AppPopups.customToast(
          message: 'An error occurred. Please reload the page and try again.');
    }
  }

  Future<void> getImage() async {
    try {
      if (mounted)
        setState(() {
          image = null;
          imageXFile = null;
        });
      final ImagePicker _picker = ImagePicker();
      XFile? temp = await _picker.pickImage(source: ImageSource.gallery);
      Uint8List? tempImage;
      if (temp != null) {
        image = await temp.readAsBytes();
      }
      if (mounted)
        setState(() {
          imageXFile = temp;
          image = tempImage;
        });
    } catch (e) {
      AppPopups.customToast(
          message: 'An error occurred capturing your image. Please try again.');
    }
  }

  Future postReply() async {
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    if (AuthenticationRepository.instance.currentUserModel.value != null &&
        replyController.text != '' &&
        replyingToId != '') {
      AppPopups.openLoadingDialog(
          "Posting your reply...", AppConstants.aInFoundLoader);

      try {
        String replyId = uuid.v1();
        String imageURL = '';
        if (imageXFile != null) {
          final storageRepository = Get.put(StorageRepository());
          var imageBytes = await imageXFile!.readAsBytes();
          imageURL = await storageRepository.uploadImage(
              imageName:
                  "${widget.postId}-${widget.commentId}-${replyId}-image.${getFileExtension(imageXFile!)}",
              bytes: imageBytes,
              path:
                  'posts/${widget.postId}/comments/${widget.commentId}/replies/${replyId}',
              contentType: imageXFile!.mimeType ?? '');
        }
        if (imageURL == '' && imageXFile != null) {
          AppPopups.closeDialog();
          AppPopups.errorSnackBar(
              title: 'Image upload failed',
              message: 'Failed to upload image. Please try again.');
          return;
        } else {
          ReplyModel newReply = ReplyModel(
              replyId: replyId,
              commentId: replyingToId,
              postId: widget.postId,
              userId:
                  AuthenticationRepository.instance.currentUserModel.value!.uid,
              comment: replyController.text,
              numUpvotes: 0,
              image: imageURL,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now());
          await DatabaseRepository.instance
              .createReply(reply: newReply)
              .then((_) {
            if (mounted)
              setState(() {
                repliesListObs.insert(0, newReply);
                isReplying = false;
                numReplies++;
                repliesVisible = true;
                replyController.clear();
                imageXFile = null;
                image = null;
              });
            AppPopups.closeDialog();
          });
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.customToast(
            message:
                'An error occurred while posting reply. Please try again.');
      }
    }
  }

  Future getNumReplies() async {
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    try {
      int temp = await DatabaseRepository.instance.getNumRepliesByComment(
          postId: widget.postId, commentId: widget.commentId);
      if (mounted) {
        setState(() {
          numReplies = temp;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred getting number of replies. Please reload the page and try again.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      if (!widget.isPreview) {
        isLikedObs = widget.isLiked;
        numUpvotesObs = widget.numUpvotes;
        getReplies(limit: 2);
      }
      replyController = TextEditingController();
    }
    super.initState();
  }

  GlobalKey replyBox = new GlobalKey();
  FocusNode replyNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            top: 0,
            bottom: 0,
            left: 17,
            child: Container(
              width: 2,
              alignment: Alignment.centerLeft,
              child: Container(
                color: widget.lastItem ?? false
                    ? Colors.transparent
                    : AppStyles.lightGrey.withAlpha(100),
                height: double.infinity,
                width: 2,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Get.toNamed("/profile/" + widget.username),
                  child: Container(
                    margin: EdgeInsets.only(right: 6),
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppStyles.pureWhite,
                      boxShadow: [
                        AppStyles().lightBoxShadow(
                            AppStyles.primaryBlack.withAlpha(150))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: widget.userProfileURL != ''
                        ? Container(
                            height: 28,
                            width: 28,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: AppRoundedImage(
                              imageType: ImageType.network,
                              image: widget.userProfileURL,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle_outlined,
                            size: 34,
                            color: AppStyles.primaryTealLighter,
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 30,
                      margin: EdgeInsets.only(
                        top: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.username,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppStyles.primaryBlack,
                                        height: 1.25),
                                  ),
                                ),
                                widget.isVerified
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 2, right: 4, top: 2),
                                        child: Icon(
                                          Icons.verified,
                                          color: AppStyles.primaryTeal,
                                          size: 18,
                                        ),
                                      )
                                    : SizedBox(
                                        width: 4,
                                      ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      widget.timestamp,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: AppStyles.lightGrey,
                                          height: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.isPreview)
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Container(
                                height: 25,
                                width: 25,
                                child: PopupMenuButton(
                                  color: AppStyles.pureWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Container(
                                    height: 24,
                                    width: 24,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.more_horiz_rounded,
                                      size: 18,
                                      color: AppStyles.mediumGray,
                                    ),
                                  ),
                                  itemBuilder: (context) {
                                    return [
                                      if (widget.userId ==
                                              (AuthenticationRepository
                                                      .instance
                                                      .currentUserModel
                                                      .value
                                                      ?.uid ??
                                                  '') ||
                                          (AuthenticationRepository
                                                  .instance
                                                  .currentUserModel
                                                  .value
                                                  ?.isAdmin ??
                                              false))
                                        PopupMenuItem(
                                          onTap: () {
                                            AppPopups.confirmDialog(
                                                title: 'Delete Comment',
                                                content:
                                                    'Are you sure you want to delete this comment?',
                                                confirmText: 'Delete',
                                                accentColor:
                                                    AppStyles.primaryRed,
                                                onConfirm: () async {
                                                  final isConnected =
                                                      await NetworkManager
                                                          .instance
                                                          .isConnected();
                                                  if (!isConnected) {
                                                    AppPopups.customToast(
                                                        message:
                                                            'No Internet Connection');
                                                    return;
                                                  }
                                                  AppPopups.popUpCircular();
                                                  try {
                                                    await DatabaseRepository
                                                        .instance
                                                        .deleteCommentById(
                                                            postId:
                                                                widget.postId,
                                                            commentId: widget
                                                                .commentId,
                                                            userId:
                                                                widget.userId);
                                                    if (widget.onDelete != null)
                                                      widget.onDelete!(
                                                          widget.commentId);
                                                    AppPopups.closeDialog();
                                                    AppPopups.closeDialog();
                                                    AppPopups.customToast(
                                                        message:
                                                            'Comment deleted');
                                                  } catch (e) {
                                                    AppPopups.closeDialog();

                                                    printDebug(e);
                                                    AppPopups.customToast(
                                                        message:
                                                            'An error occurred. Please try again.');
                                                  }
                                                });
                                          },
                                          value: 1,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 4),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  size: 25,
                                                  color: AppStyles.primaryRed,
                                                ),
                                              ),
                                              Text("Delete",
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          AppStyles.primaryRed,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      PopupMenuItem(
                                        onTap: () {
                                          if (AuthenticationRepository.instance
                                                  .currentUserModel.value !=
                                              null) {
                                            AppPopups.openReportDialog(
                                                type: 'COMMENT',
                                                postId: widget.postId,
                                                reporteeId: widget.userId,
                                                reporterId:
                                                    AuthenticationRepository
                                                        .instance
                                                        .currentUserModel
                                                        .value!
                                                        .uid,
                                                targetId: widget.commentId,
                                                title: widget.content);
                                          } else {
                                            Get.toNamed(AppRoutes.login);
                                          }
                                        },
                                        value: 2,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4),
                                              child: Icon(
                                                Icons
                                                    .report_gmailerrorred_rounded,
                                                size: 25,
                                                color: AppStyles.mediumGray,
                                              ),
                                            ),
                                            Text("Report",
                                                style: GoogleFonts.poppins(
                                                    color: AppStyles.mediumGray,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ReadMoreText(
                        widget.content,
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        colorClickableText: AppStyles.primaryTeal,
                        trimCollapsedText: ' see more',
                        trimExpandedText: ' see less',
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppStyles.primaryBlack,
                            height: 1.25),
                      ),
                    ),
                    if (widget.image != null && widget.image != '')
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 200,
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: double.infinity,
                            width: 200,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: Stack(
                              children: [
                                AppRoundedImage(
                                  imageType: ImageType.network,
                                  image: widget.image!,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 200,
                                ),
                                Material(
                                  type: MaterialType.transparency,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      AppPopups.openImageViewer(
                                          [widget.image!], 0);
                                    },
                                    hoverColor:
                                        AppStyles.lightGrey.withAlpha(30),
                                    splashColor:
                                        AppStyles.lightGrey.withAlpha(50),
                                    highlightColor:
                                        AppStyles.lightGrey.withAlpha(50),
                                    child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    if (!widget.isPreview)
                      Container(
                        height: 30,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: IconButton(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      icon: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Transform.rotate(
                                              angle: -1.5708,
                                              child: Icon(
                                                isLikedObs
                                                    ? Icons.arrow_circle_right
                                                    : Icons
                                                        .arrow_circle_right_outlined,
                                                size: 24,
                                                color: isLikedObs
                                                    ? AppStyles.primaryTeal
                                                    : AppStyles.mediumGray,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 2),
                                            child: Text(
                                                AppFormatter.approximateNumber(
                                                    numUpvotesObs),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isLikedObs
                                                      ? AppStyles.primaryTeal
                                                      : AppStyles.mediumGray,
                                                )),
                                          )
                                        ],
                                      ),
                                      onPressed: () async {
                                        if (AuthenticationRepository.instance
                                                .currentUserModel.value !=
                                            null) {
                                          if (isPerformingLike) {
                                            return;
                                          }
                                          final isConnected =
                                              await NetworkManager.instance
                                                  .isConnected();

                                          if (!isConnected) {
                                            AppPopups.customToast(
                                                message:
                                                    'No Internet Connection');
                                            return;
                                          }
                                          if (mounted)
                                            setState(() {
                                              isPerformingLike = true;
                                              isLikedObs = !isLikedObs;
                                            });
                                          if (isLikedObs) {
                                            try {
                                              if (mounted)
                                                setState(() {
                                                  numUpvotesObs++;
                                                });
                                              await DatabaseRepository.instance
                                                  .commentLiked(
                                                      postId: widget.postId,
                                                      commentId:
                                                          widget.commentId);
                                            } catch (e) {
                                              AppPopups.customToast(
                                                  message:
                                                      'An error occurred lioking comment. Please try again.');
                                              if (mounted)
                                                setState(() {
                                                  isLikedObs = false;

                                                  if (numUpvotesObs > 0)
                                                    numUpvotesObs--;
                                                });
                                            }
                                          } else {
                                            try {
                                              if (mounted)
                                                setState(() {
                                                  if (numUpvotesObs > 0)
                                                    numUpvotesObs--;
                                                });
                                              await DatabaseRepository.instance
                                                  .commentUnliked(
                                                      postId: widget.postId,
                                                      commentId:
                                                          widget.commentId);
                                            } catch (e) {
                                              AppPopups.customToast(
                                                  message:
                                                      'An error occurred disliking comment. Please try again.');
                                              if (mounted)
                                                setState(() {
                                                  isLikedObs = true;
                                                  numUpvotesObs++;
                                                });
                                            }
                                          }
                                          if (mounted)
                                            setState(() {
                                              isPerformingLike = false;
                                            });
                                        } else {
                                          Get.toNamed(AppRoutes.login);
                                        }
                                      },
                                      hoverColor: AppStyles.primaryTealLightest,
                                      highlightColor:
                                          AppStyles.primaryTealLightest,
                                      splashColor: AppStyles.primaryTealLighter,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: IconButton(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      icon: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 2),
                                              child: Icon(
                                                Icons.reply,
                                                size: 20,
                                                color: AppStyles.mediumGray,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 2),
                                            child: Text("Reply",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppStyles.mediumGray,
                                                )),
                                          ),
                                        ],
                                      ),
                                      onPressed: () async {
                                        if (AuthenticationRepository.instance
                                                .currentUserModel.value ==
                                            null) {
                                          Get.toNamed(AppRoutes.login);
                                        } else {
                                          if (mounted)
                                            setState(() {
                                              replyingTo = widget.username;
                                              replyingToId = widget.commentId;
                                              printDebug(
                                                  "Replying to: ${replyingTo} (${replyingToId})");
                                              isReplyingToComment = true;
                                              isReplying = true;
                                            });

                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (replyBox.currentContext !=
                                                null) {
                                              Scrollable.ensureVisible(
                                                replyBox.currentContext!,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                            // Request focus after scrolling to the widget
                                            replyNode.requestFocus();
                                          });
                                        }
                                      },
                                      hoverColor: AppStyles.primaryTealLightest,
                                      highlightColor:
                                          AppStyles.primaryTealLightest,
                                      splashColor: AppStyles.primaryTealLighter,
                                    ),
                                  ),
                                  numReplies > 0
                                      ? Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: IconButton(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6),
                                            icon: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 4, right: 2),
                                                  child: Text(
                                                      repliesVisible
                                                          ? "Hide replies"
                                                          : "See replies (${AppFormatter.approximateNumber(numReplies)})",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppStyles
                                                            .mediumGray,
                                                      )),
                                                ),
                                                Icon(
                                                  repliesVisible
                                                      ? Icons.arrow_drop_up
                                                      : Icons.arrow_drop_down,
                                                  size: 20,
                                                  color: AppStyles.mediumGray,
                                                ),
                                              ],
                                            ),
                                            onPressed: () async {
                                              if (repliesVisible) {
                                                if (mounted)
                                                  setState(() {
                                                    repliesVisible = false;
                                                  });
                                              } else {
                                                if (repliesListObs.length ==
                                                    0) {
                                                  if (isFetchingReplies ==
                                                      false) {
                                                    if (mounted)
                                                      setState(() {
                                                        isFetchingReplies =
                                                            true;
                                                      });
                                                    await getReplies();
                                                    if (mounted)
                                                      setState(() {
                                                        isFetchingReplies =
                                                            false;
                                                      });
                                                  }
                                                }
                                                if (mounted)
                                                  setState(() {
                                                    repliesVisible = true;
                                                  });
                                              }
                                            },
                                            hoverColor:
                                                AppStyles.primaryTealLightest,
                                            highlightColor:
                                                AppStyles.primaryTealLightest,
                                            splashColor:
                                                AppStyles.primaryTealLighter,
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!widget.isPreview)
                      Container(
                        width: double.infinity,
                        child: repliesVisible && repliesListObs.length != 0
                            ? Column(
                                children: [
                                  for (int i = 0;
                                      i < repliesListObs.length;
                                      i++)
                                    ReplyProvider(
                                      key: ValueKey(repliesListObs[i].postId +
                                          repliesListObs[i].commentId +
                                          repliesListObs[i].replyId +
                                          'Provider'),
                                      reply: repliesListObs[i],
                                      onReplyTap: (username, uid, postId,
                                          commentId, replyId) {
                                        if (mounted)
                                          setState(() {
                                            replyingTo = username;
                                            replyingToId = commentId;
                                            printDebug(
                                                "Replying to: ${replyingTo} (${replyingToId})");
                                            isReplyingToComment = false;
                                            isReplying = true;
                                            replyController.text =
                                                "@${username}" +
                                                    replyController.text;
                                          });
                                        Future.delayed(
                                                Duration(milliseconds: 100))
                                            .then((val) {
                                          if (replyBox.currentContext != null) {
                                            if (mounted)
                                              setState(() {
                                                Scrollable.ensureVisible(
                                                    replyBox.currentContext!,
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    curve: Curves.easeOut);
                                                replyNode.requestFocus();
                                              });
                                          }
                                        });
                                      },
                                      lastItem: i == repliesListObs.length - 1,
                                      onDelete: (replyId) async {
                                        repliesListObs.removeWhere((element) =>
                                            element.replyId == replyId);
                                        numReplies--;
                                      },
                                    ),
                                  !isFetchingReplies
                                      ? repliesHasNext
                                          ? Container(
                                              width: double.infinity,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: IconButton(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6),
                                                icon: Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4),
                                                      child: Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 20,
                                                        color: AppStyles
                                                            .mediumGray,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 2),
                                                      child: Text(
                                                          "See more replies",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppStyles
                                                                .mediumGray,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  if (isFetchingReplies ==
                                                      false) {
                                                    if (mounted)
                                                      setState(() {
                                                        isFetchingReplies =
                                                            true;
                                                      });
                                                    await getReplies(
                                                        startAfter:
                                                            repliesListObs.last
                                                                .createdAt);
                                                    if (mounted)
                                                      setState(() {
                                                        isFetchingReplies =
                                                            false;
                                                      });
                                                  }
                                                },
                                                hoverColor: AppStyles
                                                    .primaryTealLightest,
                                                highlightColor: AppStyles
                                                    .primaryTealLightest,
                                                splashColor: AppStyles
                                                    .primaryTealLighter,
                                              ),
                                            )
                                          : Container()
                                      : ReplyWidgetContainerShimmer()
                                ],
                              )
                            : Container(),
                      ),
                    if (!widget.isPreview)
                      (isReplying && image != null && imageXFile != null)
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.only(left: 36),
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      child: AppRoundedImage(
                                        borderRadius: 16,
                                        width: 100,
                                        height: 100,
                                        imageType: ImageType.memory,
                                        memoryImage: image!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: AppStyles.primaryBlack
                                                .withAlpha(80),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            iconSize: 28,
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: AppStyles.pureWhite,
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              if (mounted)
                                                setState(() {
                                                  image = null;
                                                  imageXFile = null;
                                                });
                                            },
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    if (!widget.isPreview)
                      isReplying
                          ? Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: CommentReplyComposeWidget(
                                key: replyBox,
                                usernameOrigin: replyingTo,
                                userProfileUrl: AuthenticationRepository
                                        .instance
                                        .currentUserModel
                                        .value
                                        ?.profileURL ??
                                    '',
                                onSubmit: () async {
                                  printDebug(
                                      "Replying to: ${replyingTo} (${replyingToId})\nContent: ${replyController.text}");
                                  await postReply();
                                },
                                onCancel: () {
                                  if (mounted)
                                    setState(() {
                                      isReplying = false;
                                      replyController.clear();
                                      image = null;
                                      imageXFile = null;
                                    });
                                },
                                onImageTap: () async {
                                  await getImage();
                                },
                                controller: replyController,
                                node: replyNode,
                                isComment: false,
                                isReply: isReplyingToComment,
                              ),
                            )
                          : Container(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
