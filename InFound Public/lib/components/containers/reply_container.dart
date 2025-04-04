import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

import 'package:readmore/readmore.dart';

class ReplyContainer extends StatefulWidget {
  const ReplyContainer(
      {super.key,
      required this.postId,
      required this.commentId,
      required this.replyId,
      required this.userId,
      required this.userProfileURL,
      required this.username,
      required this.timestamp,
      required this.image,
      required this.isLiked,
      required this.numUpVotes,
      required this.onReplyTap,
      required this.onLikeTap,
      required this.content,
      this.lastItem,
      this.onDelete,
      this.isPreview = false,
      required this.isVerified});
  final String userId;
  final String postId;
  final String commentId;
  final String replyId;
  final String content;
  final String userProfileURL;
  final String username;
  final bool isVerified;
  final String timestamp;
  final String? image;
  final bool isLiked;
  final int numUpVotes;
  final VoidCallback onReplyTap;
  final VoidCallback onLikeTap;
  final bool? lastItem;
  final Function(String)? onDelete;
  final bool isPreview;

  @override
  State<ReplyContainer> createState() => _ReplyContainerState();
}

class _ReplyContainerState extends State<ReplyContainer> {
  bool isLikedObs = false;
  int numUpVotesObs = 0;
  bool isPerformingLike = false;

  @override
  void initState() {
    if (mounted) {
      isLikedObs = widget.isLiked;
      numUpVotesObs = widget.numUpVotes;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 8),
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
                                        padding:
                                            EdgeInsets.only(left: 2, right: 4),
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
                                                title: 'Delete Reply',
                                                content:
                                                    'Are you sure you want to delete this reply?',
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
                                                        .deleteReplyById(
                                                            postId:
                                                                widget.postId,
                                                            commentId: widget
                                                                .commentId,
                                                            replyId:
                                                                widget.replyId,
                                                            userId:
                                                                widget.userId)
                                                        .then((value) {
                                                      if (widget.onDelete !=
                                                          null)
                                                        widget.onDelete!(
                                                            widget.replyId);
                                                      AppPopups.closeDialog();
                                                      AppPopups.closeDialog();
                                                      AppPopups.customToast(
                                                          message:
                                                              'Reply deleted');
                                                    });
                                                  } catch (e) {
                                                    AppPopups.closeDialog();
                                                    printDebug(e);
                                                    AppPopups.customToast(
                                                        message:
                                                            'Error occurred during deletion of reply. Please try again.');
                                                    return;
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
                                                type: 'REPLY',
                                                postId: widget.postId,
                                                commentId: widget.commentId,
                                                reporteeId: widget.userId,
                                                reporterId:
                                                    AuthenticationRepository
                                                        .instance
                                                        .currentUserModel
                                                        .value!
                                                        .uid,
                                                targetId: widget.replyId,
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
                                                    numUpVotesObs),
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
                                        widget.onLikeTap();
                                        if (isPerformingLike) {
                                          return;
                                        }
                                        final isConnected = await NetworkManager
                                            .instance
                                            .isConnected();

                                        if (!isConnected) {
                                          AppPopups.customToast(
                                              message:
                                                  'No Internet Connection');
                                          return;
                                        }
                                        if (AuthenticationRepository.instance
                                                .currentUserModel.value ==
                                            null) {
                                          Get.toNamed(AppRoutes.login);
                                        } else {
                                          if (mounted)
                                            setState(() {
                                              isLikedObs = !isLikedObs;
                                              isPerformingLike = true;
                                            });
                                          if (isLikedObs) {
                                            try {
                                              if (mounted)
                                                setState(() {
                                                  numUpVotesObs++;
                                                });
                                              await DatabaseRepository.instance
                                                  .replyLiked(
                                                      postId: widget.postId,
                                                      commentId:
                                                          widget.commentId,
                                                      replyId: widget.replyId);
                                            } catch (e) {
                                              AppPopups.customToast(
                                                  message:
                                                      'Error occurred during liking reply. Please try again.');
                                              if (mounted)
                                                setState(() {
                                                  isLikedObs = false;
                                                  if (numUpVotesObs > 0)
                                                    numUpVotesObs--;
                                                });
                                            }
                                          } else {
                                            try {
                                              if (mounted)
                                                setState(() {
                                                  if (numUpVotesObs > 0)
                                                    numUpVotesObs--;
                                                });
                                              await DatabaseRepository.instance
                                                  .replyUnliked(
                                                      postId: widget.postId,
                                                      commentId:
                                                          widget.commentId,
                                                      replyId: widget.replyId);
                                            } catch (e) {
                                              AppPopups.customToast(
                                                  message:
                                                      'Error occurred during disliking reply. Please try again.');
                                              if (mounted)
                                                setState(() {
                                                  isLikedObs = true;
                                                  numUpVotesObs++;
                                                });
                                            }
                                          }
                                          if (mounted)
                                            setState(() {
                                              isPerformingLike = false;
                                            });
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
                                      onPressed: () {
                                        if (AuthenticationRepository.instance
                                                .currentUserModel.value ==
                                            null) {
                                          Get.toNamed(AppRoutes.login);
                                        } else {
                                          if (mounted)
                                            setState(() {
                                              widget.onReplyTap();
                                            });
                                        }
                                      },
                                      hoverColor: AppStyles.primaryTealLightest,
                                      highlightColor:
                                          AppStyles.primaryTealLightest,
                                      splashColor: AppStyles.primaryTealLighter,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
