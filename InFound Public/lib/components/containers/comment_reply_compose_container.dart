import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/utils/styles.dart';

class CommentReplyComposeWidget extends StatelessWidget {
  const CommentReplyComposeWidget({
    super.key,
    required this.usernameOrigin,
    required this.userProfileUrl,
    required this.onSubmit,
    required this.onCancel,
    required this.controller,
    required this.isComment,
    required this.isReply,
    required this.node,
    required this.onImageTap,
  });

  final String usernameOrigin;
  final String userProfileUrl;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final TextEditingController controller;
  final FocusNode node;
  final bool isComment;
  final bool isReply;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: 8, top: 14),
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppStyles.pureWhite,
              boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
            ),
            alignment: Alignment.center,
            child: userProfileUrl != ''
                ? Container(
                    height: 28,
                    width: 28,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppRoundedImage(
                      imageType: ImageType.network,
                      image: userProfileUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.account_circle_outlined,
                    size: 34,
                    color: AppStyles.primaryTealLighter,
                  ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                        "${isComment ? "Commenting on" : "Replying to"} ${usernameOrigin}'s ${isComment ? "post" : isReply ? "comment" : "reply"}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 10, color: AppStyles.lightGrey, height: 1)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppStyles.bgGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(4),
                    child: IntrinsicHeight(
                      child: TextField(
                        controller: controller,
                        focusNode: node,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.roboto(fontSize: 14, color: AppStyles.primaryBlack),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: isComment ? 'Write a comment...' : 'Write a reply...',
                          hintStyle: GoogleFonts.roboto(fontSize: 14, color: AppStyles.mediumGray),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 20,
                              color: AppStyles.mediumGray,
                            ),
                            onPressed: () {
                              onImageTap();
                            },
                            hoverColor: AppStyles.primaryTealLightest,
                            highlightColor: AppStyles.primaryTealLightest,
                            splashColor: AppStyles.primaryTealLighter,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: TextButton(
                                    onPressed: () {
                                      onCancel();
                                    },
                                    child: Text('Cancel',
                                        style: GoogleFonts.poppins(fontSize: 12, color: AppStyles.mediumGray))),
                              ),
                              MaterialButtonIcon(
                                buttonPadding: EdgeInsets.symmetric(horizontal: 12),
                                height: 30,
                                onTap: () {
                                  onSubmit();
                                },
                                withText: true,
                                withIcon: false,
                                text: isComment ? "Comment" : "Reply",
                                buttonColor: AppStyles.primaryTeal,
                                highlightColor: AppStyles.primaryTealDarker,
                                splashColor: AppStyles.primaryTealDarkest,
                                fontSize: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
