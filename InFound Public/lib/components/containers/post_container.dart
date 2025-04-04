import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infound/components/containers/comment_reply_compose_container.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/main.dart';
import 'package:infound/models/comment_model.dart';
import 'package:infound/models/post_model.dart';
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

class PostContainer extends StatefulWidget {
  final String uid;
  final String username;
  final bool isVerified;
  final String userProfileURL;
  final String postId;
  final String timestamp;
  final String type;
  final String title;
  final String? description;
  final String? location;
  final String? itemColor;
  final String? itemSize;
  final String? itemBrand;
  final List<String> images;
  final int numUpvotes;
  final int numComments;
  final bool expanded;
  final bool withComments;
  final bool isBookmarked;
  final bool isLiked;
  final Function(bool, String)? onBookmarkCallback;
  final Function(String)? onDelete;
  final Future<void> Function(String)? onChangeType;
  final bool isPreview;
  final PostModel postModel;

  PostContainer(
      {super.key,
      required this.uid,
      required this.username,
      required this.userProfileURL,
      required this.isVerified,
      required this.postId,
      required this.timestamp,
      required this.type,
      required this.title,
      this.description,
      this.location,
      this.itemColor,
      this.itemSize,
      this.itemBrand,
      this.images = const [],
      this.numUpvotes = 0,
      this.numComments = 0,
      this.expanded = false,
      this.withComments = false,
      this.isBookmarked = false,
      this.isLiked = false,
      this.onBookmarkCallback,
      this.onDelete,
      this.onChangeType,
      this.isPreview = false,
      required this.postModel});

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  late TextEditingController commentController;
  Uint8List? image = null;
  XFile? imageXFile = null;

  bool isCommenting = false;
  bool isBookmarkedObs = false;
  bool isLikedObs = false;
  int numUpvotesObs = 0;
  int numCommentsObs = 0;
  List<CommentModel> commentsListObs = <CommentModel>[];
  bool commentsHasNext = true;
  bool isFetchingComments = false;
  bool isPerformingLike = false;
  bool isPerformingBookmark = false;

  String typeObs = '';
  String timestampObs = '';
  String titleObs = '';
  String? descriptionObs;
  String? locationObs;
  String? itemColorObs;
  String? itemSizeObs;
  String? itemBrandObs;
  List<String> imagesObs = [];

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
        tempImage = await temp.readAsBytes();
      }
      if (mounted)
        setState(() {
          imageXFile = temp;
          image = tempImage;
        });
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred while selecting image. Please try again.');
    }
  }

  Future getComments({DateTime? startAfter, int? limit}) async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      List<CommentModel> temp = await DatabaseRepository.instance
          .getAllCommentsByPost(
              postId: widget.postId,
              withReplies: false,
              limit: limit ?? AppConstants.nLimitComments,
              startAfter: startAfter);
      if (mounted) {
        setState(() {
          if (temp.length < (limit ?? AppConstants.nLimitComments) ||
              temp.length == 0) commentsHasNext = false;
          commentsListObs.addAll(temp);
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred while fetching comments. Please reload page and try again.');
    }
  }

  Future postComment() async {
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    if (AuthenticationRepository.instance.currentUserModel.value != null &&
        commentController.text != '') {
      AppPopups.openLoadingDialog(
          "Posting your comment...", AppConstants.aInFoundLoader);
      try {
        String commentId = uuid.v1();
        String imageURL = '';
        if (imageXFile != null) {
          final storageRepository = Get.put(StorageRepository());
          var imageBytes = await imageXFile!.readAsBytes();
          imageURL = await storageRepository.uploadImage(
              imageName:
                  "${widget.postId}-${commentId}-image.${getFileExtension(imageXFile!)}",
              bytes: imageBytes,
              path: 'posts/${widget.postId}/comments/${commentId}',
              contentType: imageXFile!.mimeType ?? '');
        }
        if (imageURL == '' && imageXFile != null) {
          AppPopups.closeDialog();
          AppPopups.errorSnackBar(
              title: 'Image upload failed',
              message: 'Failed to upload image. Please try again.');
          return;
        } else {
          CommentModel newComment = CommentModel(
              commentId: commentId,
              postId: widget.postId,
              userId:
                  AuthenticationRepository.instance.currentUserModel.value!.uid,
              comment: commentController.text,
              numUpvotes: 0,
              repliesId: [],
              replies: [],
              createdAt: DateTime.now(),
              image: imageURL,
              updatedAt: DateTime.now());
          await DatabaseRepository.instance
              .createComment(comment: newComment)
              .then((_) {
            if (mounted) {
              setState(() {
                numCommentsObs++;
                commentsListObs.insert(0, newComment);
                isCommenting = false;
                commentController.clear();
                imageXFile = null;
                image = null;
              });
            }
            AppPopups.closeDialog();
          });
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.customToast(
            message:
                'An error occurred while posting comment. Please try again.');
      }
    }
  }

  Future getNumComments() async {
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    try {
      int numCommentsTemp = await DatabaseRepository.instance
          .getNumCommentsByPost(postId: widget.postId);
      if (mounted) {
        setState(() {
          numCommentsObs = numCommentsTemp;
        });
      }
    } catch (e) {
      AppPopups.customToast(
          message:
              'An error occurred while fetching comments. Please reload page and try again.');
    }
  }

  @override
  void initState() {
    if (mounted) {
      if (!widget.isPreview) {
        getNumComments();
        getComments();
        isBookmarkedObs = widget.isBookmarked;
        isLikedObs = widget.isLiked;
        numUpvotesObs = widget.numUpvotes;
      }

      typeObs = widget.type;
      timestampObs = widget.timestamp;
      titleObs = widget.title;
      descriptionObs = widget.description;
      locationObs = widget.location;
      itemColorObs = widget.itemColor;
      itemSizeObs = widget.itemSize;
      itemBrandObs = widget.itemBrand;
      imagesObs = widget.images;

      commentController = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  GlobalKey commentBox = new GlobalKey();
  FocusNode commentNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Get.toNamed("/profile/" + widget.username),
                    child: Container(
                      margin: EdgeInsets.only(right: 6),
                      height: 44,
                      width: 44,
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
                              height: 35,
                              width: 35,
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
                              size: 42,
                              color: AppStyles.primaryTealLighter,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Flexible(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                          "/profile/" + widget.username);
                                    },
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
                                ),
                              ),
                              if (widget.isVerified)
                                Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: Icon(
                                    Icons.verified,
                                    color: AppStyles.primaryTeal,
                                    size: 18,
                                  ),
                                )
                            ],
                          ),
                        ),
                        Text(
                          timestampObs,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppStyles.lightGrey,
                              height: 1.5),
                        )
                      ],
                    ),
                  ),
                ),
                if (!widget.isPreview)
                  Padding(
                    padding: EdgeInsets.only(left: 12),
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
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              typeObs != "RESOLVED")
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as resolved',
                                    content:
                                        'Are you sure you want to mark this post as resolved?',
                                    confirmText: 'Resolve',
                                    accentColor: AppStyles.primaryTeal,
                                    onConfirm: () async {
                                      AppPopups.popUpCircular();
                                      if (widget.onChangeType != null)
                                        await widget.onChangeType!('RESOLVED');
                                      if (mounted)
                                        setState(() {
                                          typeObs = "RESOLVED";
                                        });
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      AppPopups.customToast(
                                          message: 'Post marked as resolved');
                                    });
                              },
                              value: 1,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 25,
                                      color: AppStyles.primaryTeal,
                                    ),
                                  ),
                                  Text("Mark as resolved",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryTeal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              typeObs != "EXPIRED")
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as expired',
                                    content:
                                        'Are you sure you want to mark this post as expired?',
                                    confirmText: 'Expire',
                                    accentColor: AppStyles.mediumGray,
                                    onConfirm: () async {
                                      AppPopups.popUpCircular();
                                      if (widget.onChangeType != null)
                                        await widget.onChangeType!('EXPIRED');
                                      if (mounted)
                                        setState(() {
                                          typeObs = "EXPIRED";
                                        });
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      AppPopups.customToast(
                                          message: 'Post marked as expired');
                                    });
                              },
                              value: 2,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.timer_off_outlined,
                                      size: 25,
                                      color: AppStyles.mediumGray,
                                    ),
                                  ),
                                  Text("Mark as expired",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.mediumGray,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              (typeObs == "RESOLVED" || typeObs == "EXPIRED"))
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as lost',
                                    content:
                                        'Are you sure you want to unresolve this post as lost?',
                                    confirmText: 'Change',
                                    accentColor: AppStyles.primaryRed,
                                    onConfirm: () async {
                                      AppPopups.popUpCircular();
                                      if (widget.onChangeType != null)
                                        await widget.onChangeType!('LOST');
                                      if (mounted)
                                        setState(() {
                                          typeObs = "LOST";
                                        });
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      AppPopups.customToast(
                                          message: 'Post marked as lost');
                                    });
                              },
                              value: 3,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.visibility_off_outlined,
                                      size: 25,
                                      color: AppStyles.primaryRed,
                                    ),
                                  ),
                                  Text("Mark as lost",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              (typeObs == "RESOLVED" || typeObs == "EXPIRED"))
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as found',
                                    content:
                                        'Are you sure you want to unresolve this post as found?',
                                    confirmText: 'Change',
                                    accentColor: AppStyles.primaryYellow,
                                    onConfirm: () async {
                                      AppPopups.popUpCircular();
                                      if (widget.onChangeType != null)
                                        await widget.onChangeType!('FOUND');
                                      if (mounted)
                                        setState(() {
                                          typeObs = "FOUND";
                                        });
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      AppPopups.customToast(
                                          message: 'Post marked as found');
                                    });
                              },
                              value: 4,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 25,
                                      color: AppStyles.primaryYellow,
                                    ),
                                  ),
                                  Text("Mark as found",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryYellow,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              (typeObs == "RESOLVED" || typeObs == "EXPIRED"))
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as general',
                                    content:
                                        'Are you sure you want to unresolve this post as general?',
                                    confirmText: 'Change',
                                    accentColor: AppStyles.primaryTeal,
                                    onConfirm: () async {
                                      AppPopups.popUpCircular();
                                      if (widget.onChangeType != null)
                                        await widget.onChangeType!('GENERAL');
                                      if (mounted)
                                        setState(() {
                                          typeObs = "GENERAL";
                                        });
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      AppPopups.customToast(
                                          message: 'Post marked as general');
                                    });
                              },
                              value: 5,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.question_answer_outlined,
                                      size: 25,
                                      color: AppStyles.primaryTeal,
                                    ),
                                  ),
                                  Text("Mark as general",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryTeal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((widget.uid ==
                                      (AuthenticationRepository.instance
                                              .currentUserModel.value?.uid ??
                                          '') ||
                                  (AuthenticationRepository.instance
                                          .currentUserModel.value?.isAdmin ??
                                      false)) &&
                              (typeObs == "LOST" ||
                                  typeObs == "FOUND" ||
                                  typeObs == "GENERAL"))
                            PopupMenuItem(
                              onTap: () {
                                AppPopups.openComposeBox(
                                  username: widget.username,
                                  uid: widget.uid,
                                  profileURL: widget.userProfileURL,
                                  isVerified: widget.isVerified,
                                  isEditing: true,
                                  onEdit: (postModel) {
                                    if (mounted)
                                      setState(() {
                                        typeObs = postModel.type;
                                        titleObs = postModel.title;
                                        descriptionObs = postModel.description;
                                        locationObs = postModel.location;
                                        itemColorObs = postModel.itemColor;
                                        itemSizeObs = postModel.itemSize;
                                        itemBrandObs = postModel.itemBrand;
                                        imagesObs = postModel.imagesURL;
                                      });
                                  },
                                  ePost: widget.postModel,
                                  ePostType: typeObs,
                                  ePostId: widget.postId,
                                  eDescription: descriptionObs,
                                  eLocation: locationObs,
                                  eItemColor: itemColorObs,
                                  eItemSize: itemSizeObs,
                                  eItemBrand: itemBrandObs,
                                  eImages: imagesObs,
                                  eTitle: titleObs,
                                );
                              },
                              value: 6,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 25,
                                      color: AppStyles.primaryYellow,
                                    ),
                                  ),
                                  Text("Edit",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryYellow,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if ((AuthenticationRepository
                                  .instance.currentUserModel.value?.isAdmin ??
                              false))
                            PopupMenuItem(
                              onTap: () {
                                AppPopups.confirmDialog(
                                    title: 'Delete Post',
                                    content:
                                        'Are you sure you want to delete this post?',
                                    confirmText: 'Delete',
                                    accentColor: AppStyles.primaryRed,
                                    onConfirm: () async {
                                      final isConnected = await NetworkManager
                                          .instance
                                          .isConnected();

                                      if (!isConnected) {
                                        AppPopups.customToast(
                                            message: 'No Internet Connection');
                                        return;
                                      }
                                      AppPopups.popUpCircular();
                                      try {
                                        await DatabaseRepository.instance
                                            .deletePostById(
                                                postId: widget.postId,
                                                userId: widget.uid)
                                            .then((_) {
                                          if (widget.onDelete != null)
                                            widget.onDelete!(widget.postId);
                                          AppPopups.closeDialog();
                                          AppPopups.closeDialog();
                                          AppPopups.customToast(
                                              message: 'Post deleted');
                                        });
                                      } catch (e) {
                                        AppPopups.closeDialog();
                                        printDebug(e);
                                        AppPopups.customToast(
                                            message:
                                                'An error occurred while deleting post. Please try again.');
                                      }
                                    });
                              },
                              value: 7,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 25,
                                      color: AppStyles.primaryRed,
                                    ),
                                  ),
                                  Text("Delete",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.primaryRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          if (widget.uid !=
                              (AuthenticationRepository
                                      .instance.currentUserModel.value?.uid ??
                                  ''))
                            PopupMenuItem(
                              onTap: () {
                                if (AuthenticationRepository
                                        .instance.currentUserModel.value !=
                                    null) {
                                  AppPopups.openReportDialog(
                                      type: 'POST',
                                      postId: widget.postId,
                                      reporteeId: widget.uid,
                                      reporterId: AuthenticationRepository
                                          .instance.currentUserModel.value!.uid,
                                      targetId: widget.postId,
                                      title: titleObs);
                                } else {
                                  Get.toNamed(AppRoutes.login);
                                }
                              },
                              value: 8,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.report_gmailerrorred_rounded,
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
                !widget.expanded && !widget.isPreview
                    ? Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: IconButton(
                          icon: Icon(
                            Icons.open_in_full_rounded,
                            size: 18,
                            color: AppStyles.mediumGray,
                          ),
                          onPressed: () {
                            printDebug("Expanding to post: ${widget.postId}");
                            Get.toNamed("/post/" + widget.postId);
                          },
                          hoverColor: AppStyles.primaryTealLightest,
                          highlightColor: AppStyles.primaryTealLightest,
                          splashColor: AppStyles.primaryTealLighter,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8),
            margin: EdgeInsets.only(top: 12),
            child: MouseRegion(
              cursor: (!widget.isPreview && !widget.expanded)
                  ? SystemMouseCursors.click
                  : MouseCursor.defer,
              child: GestureDetector(
                onTap: () {
                  if (!widget.isPreview && !widget.expanded)
                    Get.toNamed("/post/" + widget.postId);
                },
                child: Text.rich(
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.primaryBlack,
                        height: 1),
                    TextSpan(children: [
                      WidgetSpan(
                          child: Transform.translate(
                        offset: Offset(0, -4),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                          margin: EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                              color: typeObs == "LOST"
                                  ? AppStyles.primaryRed
                                  : typeObs == "FOUND"
                                      ? AppStyles.primaryYellow
                                      : typeObs == "RESOLVED"
                                          ? AppStyles.primaryGreen
                                          : typeObs == "GENERAL"
                                              ? AppStyles.primaryTeal
                                              : AppStyles.mediumGray,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            typeObs,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppStyles.pureWhite),
                          ),
                        ),
                      )),
                      TextSpan(text: titleObs)
                    ])),
              ),
            ),
          ),
          (descriptionObs != null && descriptionObs != "")
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: widget.expanded
                      ? Text(
                          descriptionObs!,
                          style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppStyles.primaryBlack,
                              height: 1.25),
                        )
                      : ReadMoreText(
                          descriptionObs!,
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
                )
              : Container(),
          ((locationObs != null && locationObs != "") ||
                  (itemColorObs != null && itemColorObs != "") ||
                  (itemSizeObs != null && itemSizeObs != "") ||
                  (itemBrandObs != null && itemBrandObs != ""))
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 24, right: 8, top: 8),
                  child: Column(
                    children: [
                      (itemColorObs != null && itemColorObs != "")
                          ? Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.color_lens_outlined,
                                    color: AppStyles.lightGrey,
                                    size: 16,
                                  )),
                              Text(
                                "Color: ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: AppStyles.lightGrey),
                              ),
                              Expanded(
                                  child: MouseRegion(
                                cursor: SystemMouseCursors.text,
                                child: Text(
                                  itemColorObs!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: AppStyles.primaryTealLighter),
                                ),
                              ))
                            ])
                          : Container(),
                      (itemSizeObs != null && itemSizeObs != "")
                          ? Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.format_line_spacing_outlined,
                                    color: AppStyles.lightGrey,
                                    size: 16,
                                  )),
                              Text(
                                "Size: ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: AppStyles.lightGrey),
                              ),
                              Expanded(
                                  child: MouseRegion(
                                cursor: SystemMouseCursors.text,
                                child: Text(
                                  itemSizeObs!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: AppStyles.primaryTealLighter),
                                ),
                              ))
                            ])
                          : Container(),
                      (itemBrandObs != null && itemBrandObs != "")
                          ? Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.loyalty_outlined,
                                    color: AppStyles.lightGrey,
                                    size: 16,
                                  )),
                              Text(
                                "Brand: ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: AppStyles.lightGrey),
                              ),
                              Expanded(
                                  child: MouseRegion(
                                cursor: SystemMouseCursors.text,
                                child: Text(
                                  itemBrandObs!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: AppStyles.primaryTealLighter),
                                ),
                              ))
                            ])
                          : Container(),
                      (locationObs != null && locationObs != "")
                          ? Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: AppStyles.lightGrey,
                                    size: 16,
                                  )),
                              Text(
                                "Location: ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: AppStyles.lightGrey),
                              ),
                              Expanded(
                                  child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onTap: () {
                                      var coords = AppFormatter.parseLocation(
                                          locationObs!);
                                      AppPopups.openMapViewer(
                                          currentLatitude: coords[0],
                                          currentLongitude: coords[1],
                                          currentRadius: coords[2],
                                          onSubmit: (p1, p2) {});
                                    },
                                    child: Text(
                                      locationObs!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: AppStyles.primaryTealLighter),
                                    )),
                              ))
                            ])
                          : Container(),
                    ],
                  ))
              : Container(),
          imagesObs.isNotEmpty
              ? Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: 664),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.only(top: 12),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 600,
                      height: imagesObs.length <= 3
                          ? (600 / imagesObs.length)
                          : (600),
                      child: StaggeredGrid.count(
                        crossAxisCount:
                            imagesObs.length <= 3 ? imagesObs.length : 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: [
                          for (int i = 0; i < imagesObs.length; i++)
                            StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: (imagesObs.length > 4 && i == 3)
                                        ? Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: AppRoundedImage(
                                                  imageType: ImageType.network,
                                                  image: imagesObs[i],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Material(
                                                type: MaterialType.transparency,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    AppPopups.openImageViewer(
                                                        imagesObs, i);
                                                  },
                                                  hoverColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(30),
                                                  splashColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(50),
                                                  highlightColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(50),
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      color: AppStyles
                                                          .primaryBlack
                                                          .withAlpha(100),
                                                      child: Center(
                                                        child: Text(
                                                          '+${imagesObs.length - 4}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 40,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppStyles
                                                                      .pureWhite),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: AppRoundedImage(
                                                  imageType: ImageType.network,
                                                  image: imagesObs[i],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Material(
                                                type: MaterialType.transparency,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    AppPopups.openImageViewer(
                                                        imagesObs, i);
                                                  },
                                                  hoverColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(30),
                                                  splashColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(50),
                                                  highlightColor: AppStyles
                                                      .lightGrey
                                                      .withAlpha(50),
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))),
                        ],
                      ),
                    ),
                  ))
              : Container(),
          if (!widget.isPreview)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(
                color: AppStyles.lightGrey,
              ),
            ),
          if (!widget.isPreview)
            Container(
              height: 36,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            icon: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Transform.rotate(
                                    angle: -1.5708,
                                    child: Icon(
                                      isLikedObs
                                          ? Icons.arrow_circle_right
                                          : Icons.arrow_circle_right_outlined,
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
                              if (AuthenticationRepository
                                      .instance.currentUserModel.value !=
                                  null) {
                                if (isPerformingLike) {
                                  return;
                                }
                                final isConnected =
                                    await NetworkManager.instance.isConnected();

                                if (!isConnected) {
                                  AppPopups.customToast(
                                      message: 'No Internet Connection');
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
                                        .postLiked(postId: widget.postId);
                                  } catch (e) {
                                    AppPopups.customToast(
                                        message:
                                            'An error occurred while liking post. Please try again.');
                                    if (mounted)
                                      setState(() {
                                        isLikedObs = false;

                                        if (numUpvotesObs > 0) numUpvotesObs--;
                                      });
                                  }
                                } else {
                                  try {
                                    if (mounted)
                                      setState(() {
                                        if (numUpvotesObs > 0) numUpvotesObs--;
                                      });
                                    await DatabaseRepository.instance
                                        .postUnliked(postId: widget.postId);
                                  } catch (e) {
                                    AppPopups.customToast(
                                        message:
                                            'An error occurred while disliking post. Please try again.');
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
                            highlightColor: AppStyles.primaryTealLightest,
                            splashColor: AppStyles.primaryTealLighter,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            icon: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 22,
                                    color: AppStyles.mediumGray,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Text(
                                      AppFormatter.approximateNumber(
                                          numCommentsObs),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppStyles.mediumGray,
                                      )),
                                )
                              ],
                            ),
                            onPressed: () async {
                              if (widget.withComments &&
                                  AuthenticationRepository
                                          .instance.currentUserModel.value !=
                                      null) {
                                if (mounted)
                                  setState(() {
                                    commentController.clear();
                                    image = null;
                                    imageXFile = null;
                                    isCommenting = !isCommenting;
                                  });
                                if (isCommenting) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (commentBox.currentContext != null) {
                                      Scrollable.ensureVisible(
                                        commentBox.currentContext!,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                    // Request focus after scrolling to the widget
                                    commentNode.requestFocus();
                                  });
                                }
                              } else {
                                Get.toNamed("/post/" + widget.postId);
                              }
                            },
                            hoverColor: AppStyles.primaryTealLightest,
                            highlightColor: AppStyles.primaryTealLightest,
                            splashColor: AppStyles.primaryTealLighter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isBookmarkedObs
                            ? Icons.bookmark_added
                            : Icons.bookmark_add_outlined,
                        size: 25,
                        color: isBookmarkedObs
                            ? AppStyles.primaryTeal
                            : AppStyles.mediumGray,
                      ),
                      onPressed: () async {
                        if (AuthenticationRepository
                                .instance.currentUserModel.value !=
                            null) {
                          if (isPerformingBookmark) {
                            return;
                          }
                          final isConnected =
                              await NetworkManager.instance.isConnected();

                          if (!isConnected) {
                            AppPopups.customToast(
                                message: 'No Internet Connection');
                            return;
                          }
                          if (mounted)
                            setState(() {
                              isPerformingBookmark = true;
                              isBookmarkedObs = !isBookmarkedObs;
                            });
                          if (isBookmarkedObs) {
                            try {
                              await DatabaseRepository.instance
                                  .postBookmarked(postId: widget.postId)
                                  .then((_) {
                                AuthenticationRepository
                                    .instance.currentUserBookmarks
                                    .add(widget.postId);
                                AppPopups.customToast(
                                    message: 'Post bookmarked');
                                if (mounted)
                                  setState(() {
                                    if (widget.onBookmarkCallback != null) {
                                      widget.onBookmarkCallback!(
                                          isBookmarkedObs, widget.postId);
                                    }
                                  });
                              });
                            } catch (e) {
                              AppPopups.customToast(
                                  message:
                                      'An error occurred while bookmarking post. Please try again.');
                            }
                          } else {
                            try {
                              await DatabaseRepository.instance
                                  .postUnbookmarked(postId: widget.postId)
                                  .then((_) {
                                AuthenticationRepository
                                    .instance.currentUserBookmarks
                                    .remove(widget.postId);
                                AppPopups.customToast(
                                    message: 'Post removed from bookmarks');
                                if (mounted)
                                  setState(() {
                                    if (widget.onBookmarkCallback != null) {
                                      widget.onBookmarkCallback!(
                                          isBookmarkedObs, widget.postId);
                                    }
                                  });
                              });
                            } catch (e) {
                              AppPopups.customToast(
                                  message:
                                      'An error occurred while bookmarking post. Please try again.');
                            }
                          }
                          if (mounted)
                            setState(() {
                              isPerformingBookmark = false;
                            });
                        } else {
                          Get.toNamed(AppRoutes.login);
                        }
                      },
                      hoverColor: AppStyles.primaryTealLightest,
                      highlightColor: AppStyles.primaryTealLightest,
                      splashColor: AppStyles.primaryTealLighter,
                    ),
                  ),
                ],
              ),
            ),
          // Comments section
          if (widget.withComments)
            Container(
                width: double.infinity,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      for (int i = 0; i < commentsListObs.length; i++)
                        CommentProvider(
                          key: ValueKey(commentsListObs[i].postId +
                              commentsListObs[i].commentId +
                              'Provider'),
                          comment: commentsListObs[i],
                          lastItem: i == commentsListObs.length - 1,
                          onDelete: (commentId) {
                            if (mounted)
                              setState(() {
                                commentsListObs.removeWhere((element) =>
                                    element.commentId == commentId);
                                numCommentsObs--;
                              });
                          },
                        ),
                    ],
                  ),
                )),
          if (widget.withComments)
            !isFetchingComments
                ? commentsHasNext
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          icon: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: AppStyles.mediumGray,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Text("See more comments",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppStyles.mediumGray,
                                    )),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            if (isFetchingComments == false) {
                              if (mounted)
                                setState(() {
                                  isFetchingComments = true;
                                });
                              await getComments(
                                  startAfter: commentsListObs.last.createdAt);
                              if (mounted)
                                setState(() {
                                  isFetchingComments = false;
                                });
                            }
                          },
                          hoverColor: AppStyles.primaryTealLightest,
                          highlightColor: AppStyles.primaryTealLightest,
                          splashColor: AppStyles.primaryTealLighter,
                        ),
                      )
                    : Container()
                : CommentWidgetContainerShimmer(),
          if (widget.withComments)
            isCommenting && image != null && imageXFile != null
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
                                  color: AppStyles.primaryBlack.withAlpha(80),
                                  borderRadius: BorderRadius.circular(15),
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
          if (widget.withComments)
            isCommenting
                ? Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: CommentReplyComposeWidget(
                      key: commentBox,
                      usernameOrigin: widget.username,
                      userProfileUrl: AuthenticationRepository
                              .instance.currentUserModel.value?.profileURL ??
                          '',
                      onSubmit: () async {
                        printDebug(
                            "Commenting on post: ${widget.postId}\nContent: ${commentController.text}");
                        await postComment();
                      },
                      onCancel: () {
                        if (mounted)
                          setState(() {
                            isCommenting = false;
                            commentController.clear();
                            image = null;
                            imageXFile = null;
                          });
                      },
                      onImageTap: () async {
                        await getImage();
                      },
                      controller: commentController,
                      node: commentNode,
                      isComment: true,
                      isReply: false,
                    ),
                  )
                : Container(),
        ],
      ),
    );
  }
}
