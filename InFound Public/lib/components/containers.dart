import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/report_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/styles.dart';

import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchBox extends StatefulWidget {
  SearchBox({
    super.key,
    this.initialValue,
    this.onSearch,
  });

  final String? initialValue;
  final Function(String)? onSearch;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      searchController.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppStyles.pureWhite,
      ),
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.fromLTRB(24, 12, 16, 12),
      child: Container(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: TextField(
            controller: searchController,
            style: GoogleFonts.poppins(
                fontSize: 16, color: AppStyles.primaryBlack),
            decoration: InputDecoration.collapsed(
              hintText: "Search",
              hintStyle: GoogleFonts.poppins(color: AppStyles.mediumGray),
            ),
            onSubmitted: (inp) {
              if (searchController.text.isNotEmpty &&
                  searchController.text != '') {
                if (widget.onSearch != null) {
                  widget.onSearch!(searchController.text);
                } else {
                  Get.toNamed('/search?query=' + searchController.text);
                }
              } else {
                AppPopups.customToast(message: "Please enter a search query");
              }
            },
          )),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (searchController.text.isNotEmpty &&
                    searchController.text != '') {
                  if (widget.onSearch != null) {
                    widget.onSearch!(searchController.text);
                  } else {
                    Get.toNamed('/search?query=' + searchController.text);
                  }
                } else {
                  AppPopups.customToast(message: "Please enter a search query");
                }
              },
              child: Icon(
                Icons.search,
                color: AppStyles.primaryTeal,
                size: 26,
              ),
            ),
          )
        ],
      )),
    );
  }
}

class UserResultContainer extends StatefulWidget {
  const UserResultContainer(
      {super.key,
      required this.userModel,
      this.selectable = false,
      this.isChecked = false,
      this.onChange});
  final UserModel userModel;
  final bool selectable;
  final bool isChecked;
  final Function(bool)? onChange;

  @override
  State<UserResultContainer> createState() => _UserResultContainerState();
}

class _UserResultContainerState extends State<UserResultContainer> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      isChecked = widget.isChecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppStyles.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))
          ]),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppStyles.pureWhite,
              boxShadow: [
                AppStyles()
                    .lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))
              ],
            ),
            alignment: Alignment.center,
            child: widget.userModel.profileURL != ''
                ? Container(
                    height: 35,
                    width: 35,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AppRoundedImage(
                      imageType: ImageType.network,
                      image: widget.userModel.profileURL,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.account_circle_outlined,
                    size: 42,
                    color: AppStyles.primaryTealLighter,
                  ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.userModel.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: AppStyles.primaryBlack,
                                height: 1.25),
                          ),
                        ),
                        if (widget.userModel.isVerified)
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
                    "${widget.userModel.name} (${widget.userModel.email})",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppStyles.mediumGray,
                        height: 1.5),
                  )
                ],
              ),
            ),
          ),
          Checkbox(
              value: isChecked,
              activeColor: AppStyles.primaryTeal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    isChecked = value ?? false;
                    if (widget.onChange != null) {
                      widget.onChange!(isChecked);
                    }
                  });
              })
        ],
      ),
    );
  }
}

class ComposeWidget extends StatelessWidget {
  const ComposeWidget({
    super.key,
    required this.profileURL,
    required this.onPost,
  });

  final String profileURL;
  final Function(PostModel) onPost;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                    child: profileURL != ''
                        ? Container(
                            height: 35,
                            width: 35,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: AppRoundedImage(
                              imageType: ImageType.network,
                              image: profileURL,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle_outlined,
                            size: 42,
                            color: AppStyles.primaryTealLighter,
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.text,
                        child: GestureDetector(
                          onTap: () {
                            if (AuthenticationRepository
                                    .instance.currentUserModel.value !=
                                null) {
                              AppPopups.openComposeBox(
                                  username: AuthenticationRepository.instance
                                      .currentUserModel.value!.userName,
                                  uid: AuthenticationRepository
                                      .instance.currentUserModel.value!.uid,
                                  profileURL: AuthenticationRepository.instance
                                      .currentUserModel.value!.profileURL,
                                  isVerified: AuthenticationRepository.instance
                                      .currentUserModel.value!.isVerified,
                                  isEditing: false,
                                  onPost: onPost);
                            }
                          },
                          child: Text("Found or looking for something?",
                              style: GoogleFonts.poppins(
                                  fontSize: 18, color: AppStyles.mediumGray)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
            color: AppStyles.lightGrey,
          ),
          Container(
            height: 40,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 25,
                            color: AppStyles.mediumGray,
                          ),
                          onPressed: () {
                            if (AuthenticationRepository
                                    .instance.currentUserModel.value !=
                                null) {
                              AppPopups.openComposeBox(
                                  username: AuthenticationRepository.instance
                                      .currentUserModel.value!.userName,
                                  uid: AuthenticationRepository
                                      .instance.currentUserModel.value!.uid,
                                  profileURL: AuthenticationRepository.instance
                                      .currentUserModel.value!.profileURL,
                                  isVerified: AuthenticationRepository.instance
                                      .currentUserModel.value!.isVerified,
                                  isEditing: false,
                                  onPost: onPost);
                            }
                          },
                          hoverColor: AppStyles.primaryTealLightest,
                          highlightColor: AppStyles.primaryTealLightest,
                          splashColor: AppStyles.primaryTealLighter,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.list_rounded,
                            size: 25,
                            color: AppStyles.mediumGray,
                          ),
                          onPressed: () {
                            if (AuthenticationRepository
                                    .instance.currentUserModel.value !=
                                null) {
                              AppPopups.openComposeBox(
                                  username: AuthenticationRepository.instance
                                      .currentUserModel.value!.userName,
                                  uid: AuthenticationRepository
                                      .instance.currentUserModel.value!.uid,
                                  profileURL: AuthenticationRepository.instance
                                      .currentUserModel.value!.profileURL,
                                  isVerified: AuthenticationRepository.instance
                                      .currentUserModel.value!.isVerified,
                                  isEditing: false,
                                  onPost: onPost);
                            }
                          },
                          hoverColor: AppStyles.primaryTealLightest,
                          highlightColor: AppStyles.primaryTealLightest,
                          splashColor: AppStyles.primaryTealLighter,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_location_alt_outlined,
                            size: 25,
                            color: AppStyles.mediumGray,
                          ),
                          onPressed: () {
                            if (AuthenticationRepository
                                    .instance.currentUserModel.value !=
                                null) {
                              AppPopups.openComposeBox(
                                  username: AuthenticationRepository.instance
                                      .currentUserModel.value!.userName,
                                  uid: AuthenticationRepository
                                      .instance.currentUserModel.value!.uid,
                                  profileURL: AuthenticationRepository.instance
                                      .currentUserModel.value!.profileURL,
                                  isVerified: AuthenticationRepository.instance
                                      .currentUserModel.value!.isVerified,
                                  isEditing: false,
                                  onPost: onPost);
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
                  height: double.infinity,
                  width: 80,
                  child: MaterialButtonIcon(
                    onTap: () {
                      if (AuthenticationRepository
                              .instance.currentUserModel.value !=
                          null) {
                        AppPopups.openComposeBox(
                            username: AuthenticationRepository
                                .instance.currentUserModel.value!.userName,
                            uid: AuthenticationRepository
                                .instance.currentUserModel.value!.uid,
                            profileURL: AuthenticationRepository
                                .instance.currentUserModel.value!.profileURL,
                            isVerified: AuthenticationRepository
                                .instance.currentUserModel.value!.isVerified,
                            isEditing: false,
                            onPost: onPost);
                      }
                    },
                    withText: true,
                    withIcon: false,
                    text: "Post",
                    buttonColor: AppStyles.primaryTeal,
                    highlightColor: AppStyles.primaryTealDarker,
                    splashColor: AppStyles.primaryTealDarkest,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DividerWIthText extends StatelessWidget {
  final Color? color;
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? thickness;
  final double? space;

  DividerWIthText({
    super.key,
    this.color,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.thickness,
    this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
          color: color ?? AppStyles.primaryTealLighter,
          thickness: thickness ?? 2.5,
        )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: GoogleFonts.poppins(
                fontSize: fontSize ?? 18,
                color: color ?? AppStyles.primaryTealLighter,
                fontWeight: fontWeight ?? FontWeight.w600),
          ),
        ),
        Expanded(
            child: Divider(
          color: color ?? AppStyles.primaryTealLighter,
          thickness: thickness ?? 2.5,
        )),
      ],
    );
  }
}

class UserProfileContainer extends StatelessWidget {
  const UserProfileContainer({
    super.key,
    required this.uid,
    required this.userProfileURL,
    required this.username,
    required this.fullName,
    required this.bio,
    required this.email,
    required this.phone,
    required this.location,
    required this.isFullNamePublic,
    required this.isEmailPublic,
    required this.isPhonePublic,
    required this.isLocationPublic,
    required this.isVerified,
    required this.userModel,
  });

  final String uid;
  final String userProfileURL;
  final String username;
  final String fullName;
  final String bio;
  final String email;
  final String phone;
  final String location;
  final bool isVerified;

  final bool isFullNamePublic;
  final bool isEmailPublic;
  final bool isPhonePublic;
  final bool isLocationPublic;

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: AppConstants.bodyWidth, minHeight: 120),
      margin: EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(18),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    height: constraints.maxWidth <= 600 ? 50 : 80,
                    width: constraints.maxWidth <= 600 ? 50 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        AppStyles().lightBoxShadow(
                            AppStyles.primaryBlack.withAlpha(150))
                      ],
                      color: AppStyles.pureWhite,
                    ),
                    alignment: Alignment.center,
                    child: userProfileURL != ''
                        ? Container(
                            height: constraints.maxWidth <= 600 ? 40 : 66,
                            width: constraints.maxWidth <= 600 ? 40 : 66,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: AppRoundedImage(
                              imageType: ImageType.network,
                              image: userProfileURL,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle_outlined,
                            size: constraints.maxWidth <= 600 ? 48 : 78,
                            color: AppStyles.primaryTealLighter,
                          ),
                  ),
                  Expanded(
                    child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: constraints.maxWidth <= 600
                                            ? 5
                                            : 16),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            username,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w600,
                                                color: AppStyles.primaryBlack,
                                                height: 1),
                                          ),
                                        ),
                                        if (isVerified)
                                          Container(
                                              height: 32,
                                              width: 32,
                                              padding: EdgeInsets.only(left: 4),
                                              child: Icon(Icons.verified,
                                                  color: AppStyles.primaryTeal,
                                                  size: 32))
                                      ],
                                    ),
                                  ),
                                ),
                                if (uid ==
                                        (AuthenticationRepository.instance
                                                .currentUserModel.value?.uid ??
                                            "") ||
                                    (AuthenticationRepository.instance
                                            .currentUserModel.value?.isAdmin ??
                                        false))
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: constraints.maxWidth <= 600
                                            ? 6
                                            : 16,
                                        right:
                                            constraints.maxWidth <= 600 ? 4 : 8,
                                        left: constraints.maxWidth <= 600
                                            ? 6
                                            : 16),
                                    height: 32,
                                    width: 64,
                                    child: MaterialButtonIcon(
                                      onTap: () {
                                        AppPopups.openProfileEditor(
                                            user: userModel);
                                      },
                                      withText: true,
                                      withIcon: false,
                                      text: "Edit",
                                      buttonColor: AppStyles.primaryTeal,
                                      highlightColor:
                                          AppStyles.primaryTealDarker,
                                      splashColor: AppStyles.primaryTealDarkest,
                                      fontSize: 16,
                                    ),
                                  )
                              ],
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
            (isEmailPublic ||
                    isFullNamePublic ||
                    isLocationPublic ||
                    isPhonePublic ||
                    bio.isNotEmpty)
                ? Transform.translate(
                    offset: Offset(constraints.maxWidth <= 600 ? 0 : 100,
                        constraints.maxWidth <= 600 ? 0 : -28),
                    child: Container(
                      width: constraints.maxWidth <= 600
                          ? double.infinity
                          : constraints.maxWidth - 100,
                      padding: EdgeInsets.only(
                          top: constraints.maxWidth <= 600 ? 8 : 0,
                          left: constraints.maxWidth <= 600 ? 16 : 0,
                          right: constraints.maxWidth <= 600 ? 8 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isFullNamePublic && fullName != '')
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    fontSize:
                                        constraints.maxWidth <= 600 ? 14 : 16,
                                    color: AppStyles.mediumGray),
                              ),
                            ),
                          if (bio != '' || bio.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: ReadMoreText(
                                bio,
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
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isEmailPublic && email != '')
                                  Row(children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.email_outlined,
                                          color: AppStyles.lightGrey,
                                          size: 14,
                                        )),
                                    Text(
                                      "Email: ",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          fontSize: constraints.maxWidth <= 600
                                              ? 12
                                              : 14,
                                          color: AppStyles.lightGrey),
                                    ),
                                    Expanded(
                                        child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                          onTap: () async {
                                            String mailUrl = 'mailto:$email';
                                            try {
                                              await launchUrlString(mailUrl);
                                            } catch (e) {
                                              await Clipboard.setData(
                                                  ClipboardData(text: email));
                                              AppPopups.customToast(
                                                  message:
                                                      "Email copied to clipboard");
                                            }
                                          },
                                          child: Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                                fontSize:
                                                    constraints.maxWidth <= 600
                                                        ? 12
                                                        : 14,
                                                color: AppStyles
                                                    .primaryTealLighter),
                                          )),
                                    ))
                                  ]),
                                if (isPhonePublic && phone != '')
                                  Row(children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.phone_outlined,
                                          color: AppStyles.lightGrey,
                                          size: 14,
                                        )),
                                    Text(
                                      "Phone No.: ",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          fontSize: constraints.maxWidth <= 600
                                              ? 12
                                              : 14,
                                          color: AppStyles.lightGrey),
                                    ),
                                    Expanded(
                                        child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            AppFormatter.formatPhoneNumber(
                                                phone),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                                fontSize:
                                                    constraints.maxWidth <= 600
                                                        ? 12
                                                        : 14,
                                                color: AppStyles
                                                    .primaryTealLighter),
                                          )),
                                    ))
                                  ]),
                                if (isLocationPublic && location != '')
                                  Row(children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          color: AppStyles.lightGrey,
                                          size: 14,
                                        )),
                                    Text(
                                      "Location: ",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          fontSize: constraints.maxWidth <= 600
                                              ? 12
                                              : 14,
                                          color: AppStyles.lightGrey),
                                    ),
                                    Expanded(
                                        child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                                fontSize:
                                                    constraints.maxWidth <= 600
                                                        ? 12
                                                        : 14,
                                                color: AppStyles
                                                    .primaryTealLighter),
                                          )),
                                    ))
                                  ]),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'No public information available.',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppStyles.mediumGray),
                    ),
                  ),
          ],
        );
      }),
    );
  }
}

class EndOfResultContainer extends StatelessWidget {
  const EndOfResultContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.all(24),
      child: Text('-- Nothing else follows --',
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppStyles.mediumGray)),
    );
  }
}

class NoResultContainer extends StatelessWidget {
  const NoResultContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.all(24),
      child: Text('-- Nothing here --',
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppStyles.mediumGray)),
    );
  }
}

class NotificationContainer extends StatefulWidget {
  const NotificationContainer(
      {super.key,
      this.senderProfileUrl = '',
      required this.content,
      required this.timestamp,
      required this.type,
      required this.targetID,
      this.read = false,
      required this.notifId,
      required this.userId,
      required this.senderUsername,
      required this.senderUid,
      required this.postID,
      required this.onClick});

  final String notifId;
  final String userId;
  final String senderUsername;
  final String senderUid;
  final String senderProfileUrl;
  final String type;
  final String targetID;
  final String postID;
  final String content;
  final String timestamp;
  final bool read;
  final VoidCallback onClick;

  @override
  State<NotificationContainer> createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  bool readObs = false;

  @override
  void initState() {
    // TODO: implement initState
    if (mounted) {
      readObs = widget.read;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          widget.onClick();
          if (readObs == false) {
            setState(() {
              readObs = true;
            });
          }
        },
        child: Container(
          height: 80,
          constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
          margin: EdgeInsets.only(bottom: 8),
          width: double.infinity,
          decoration: BoxDecoration(
              color: readObs
                  ? AppStyles.pureWhite.withAlpha(100)
                  : AppStyles.pureWhite,
              borderRadius: BorderRadius.circular(24)),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                margin: EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    widget.type == 'LIKE'
                        ? Transform.rotate(
                            angle: -1.5708,
                            child: Icon(
                              Icons.arrow_circle_right_outlined,
                              size: 40,
                              color: readObs
                                  ? AppStyles.lightGrey
                                  : AppStyles.primaryTeal,
                            ),
                          )
                        : widget.type == 'USERREQUEST'
                            ? Icon(
                                Icons.account_circle_outlined,
                                size: 40,
                                color: readObs
                                    ? AppStyles.lightGrey
                                    : AppStyles.primaryTeal,
                              )
                            : widget.type == 'BADGE'
                                ? Icon(
                                    Icons.auto_awesome,
                                    size: 40,
                                    color: readObs
                                        ? AppStyles.lightGrey
                                        : AppStyles.primaryTeal,
                                  )
                                : Icon(
                                    Icons.chat_bubble_outline,
                                    size: 40,
                                    color: readObs
                                        ? AppStyles.lightGrey
                                        : AppStyles.primaryTeal,
                                  ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.only(right: 2),
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppStyles.pureWhite,
                          boxShadow: [
                            AppStyles().lightBoxShadow(
                                AppStyles.primaryBlack.withAlpha(150))
                          ],
                        ),
                        alignment: Alignment.center,
                        child: widget.senderProfileUrl != ''
                            ? Container(
                                height: 16,
                                width: 16,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Opacity(
                                  opacity: readObs ? 0.5 : 1,
                                  child: AppRoundedImage(
                                    imageType: ImageType.network,
                                    image: widget.senderProfileUrl,
                                    overlayColor:
                                        readObs ? AppStyles.lightGrey : null,
                                    colorBlendMode:
                                        readObs ? BlendMode.saturation : null,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.account_circle_outlined,
                                size: 18,
                                color: readObs
                                    ? AppStyles.lightGrey
                                    : AppStyles.primaryTealLighter,
                              ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    '${widget.senderUsername} ${widget.content}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: readObs
                            ? AppStyles.lightGrey
                            : AppStyles.primaryBlack,
                        height: 1.5),
                  ),
                ),
              ),
              Container(
                width: 80,
                child: Text(
                  widget.timestamp,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppStyles.lightGrey,
                      height: 1.5),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationContainerShimmer extends StatelessWidget {
  const NotificationContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            margin: EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                    height: 40,
                    width: 40,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppShimmerEffect(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      margin: EdgeInsets.only(right: 6),
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppStyles.pureWhite,
                        boxShadow: [
                          AppStyles().lightBoxShadow(
                              AppStyles.primaryBlack.withAlpha(150))
                        ],
                      ),
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      padding: EdgeInsets.all(2),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppStyles.pureWhite,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AppShimmerEffect(
                          width: double.infinity,
                          height: double.infinity,
                          radius: 0,
                        ),
                      )),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Container(
                height: 40,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppStyles.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppShimmerEffect(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 0,
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 80,
            margin: EdgeInsets.only(left: 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppStyles.lightGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppShimmerEffect(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class AppShimmerEffect extends StatelessWidget {
  const AppShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? AppStyles.pureWhite,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ReportContainer extends StatefulWidget {
  const ReportContainer({
    super.key,
    required this.report,
    required this.user,
    this.onDelete,
  });

  final ReportModel report;
  final UserModel user;
  final Function(String)? onDelete;

  @override
  State<ReportContainer> createState() => _ReportContainerState();
}

class _ReportContainerState extends State<ReportContainer> {
  String _status = 'ACTIVE';

  var reportContent;

  @override
  void initState() {
    _status = widget.report.status;
    if (widget.report.type == 'POST') {
      DatabaseRepository.instance
          .getSpecificPost(postId: widget.report.targetId)
          .then((value) {
        if (mounted)
          setState(() {
            reportContent = value;
          });
      });
    } else if (widget.report.type == 'COMMENT') {
      DatabaseRepository.instance
          .getCommentById(
              postId: widget.report.postId, commentId: widget.report.targetId)
          .then((value) {
        if (mounted)
          setState(() {
            reportContent = value;
          });
      });
    } else if (widget.report.type == 'REPLY') {
      DatabaseRepository.instance
          .getReplyById(
              postId: widget.report.postId,
              commentId: widget.report.commentId,
              replyId: widget.report.targetId)
          .then((value) {
        if (mounted)
          setState(() {
            reportContent = value;
          });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppStyles.pureWhite,
            borderRadius: BorderRadius.circular(24)),
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
                      onTap: () =>
                          Get.toNamed("/profile/" + widget.user.userName),
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
                        child: widget.user.profileURL != ''
                            ? Container(
                                height: 35,
                                width: 35,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: AppRoundedImage(
                                  imageType: ImageType.network,
                                  image: widget.user.profileURL,
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
                                            "/profile/" + widget.user.userName);
                                      },
                                      child: Text(
                                        widget.user.userName,
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
                                if (widget.user.isVerified)
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
                            timeago.format(widget.report.createdAt),
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
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed("/post/" + widget.report.postId);
                      },
                      child: Text(
                        'Go to post',
                        style: GoogleFonts.poppins(
                            color: AppStyles.primaryTeal,
                            fontSize: 16,
                            height: 1),
                      ),
                    ),
                  ),
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
                          if ((AuthenticationRepository.instance
                                      .currentUserModel.value?.isAdmin ??
                                  false) &&
                              _status == "ACTIVE")
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as resolved',
                                    content:
                                        'Are you sure you want to mark this report as resolved?',
                                    confirmText: 'Resolve',
                                    accentColor: AppStyles.primaryTeal,
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
                                            .markReportAsResolved(
                                                report: widget.report)
                                            .then((_) {
                                          AppPopups.closeDialog();
                                          AppPopups.closeDialog();
                                          if (mounted)
                                            setState(() {
                                              _status = 'RESOLVED';
                                            });
                                          AppPopups.customToast(
                                              message:
                                                  'Report marked as resolved');
                                        });
                                      } catch (e) {
                                        AppPopups.closeDialog();
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
                          if ((AuthenticationRepository.instance
                                      .currentUserModel.value?.isAdmin ??
                                  false) &&
                              _status == "ACTIVE")
                            PopupMenuItem(
                              onTap: () async {
                                AppPopups.confirmDialog(
                                    title: 'Mark as ignored',
                                    content:
                                        'Are you sure you want to mark this report as ignored?',
                                    confirmText: 'Ignore',
                                    accentColor: AppStyles.mediumGray,
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
                                            .markReportAsIgnored(
                                                report: widget.report)
                                            .then((_) {
                                          AppPopups.closeDialog();
                                          AppPopups.closeDialog();
                                          if (mounted)
                                            setState(() {
                                              _status = 'IGNORED';
                                            });
                                          AppPopups.customToast(
                                              message:
                                                  'Report marked as ignored');
                                        });
                                      } catch (e) {
                                        AppPopups.closeDialog();
                                        AppPopups.customToast(
                                            message:
                                                'An error occurred. Please try again.');
                                      }
                                    });
                              },
                              value: 2,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.visibility_off_outlined,
                                      size: 25,
                                      color: AppStyles.mediumGray,
                                    ),
                                  ),
                                  Text("Mark as ignored",
                                      style: GoogleFonts.poppins(
                                          color: AppStyles.mediumGray,
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
                                    title: 'Delete Report',
                                    content:
                                        'Are you sure you want to delete this report?',
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
                                            .deleteReportById(
                                                reportId:
                                                    widget.report.reportId)
                                            .then((_) {
                                          if (widget.onDelete != null)
                                            widget.onDelete!(
                                                widget.report.reportId);
                                          AppPopups.closeDialog();
                                          AppPopups.closeDialog();
                                        });
                                      } catch (e) {
                                        AppPopups.closeDialog();
                                        AppPopups.customToast(
                                            message:
                                                'An error occurred. Please try again.');
                                      }
                                    });
                              },
                              value: 3,
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
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.only(top: 12),
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
                            color: widget.report.type == "POST"
                                ? AppStyles.primaryRed
                                : widget.report.type == "COMMENT"
                                    ? AppStyles.primaryYellow
                                    : AppStyles.primaryTeal,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          widget.report.type,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppStyles.pureWhite),
                        ),
                      ),
                    )),
                    TextSpan(text: widget.report.reason)
                  ])),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 24, top: 8),
              child: Row(children: [
                Text(
                  'Status: ',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppStyles.mediumGray, height: 1),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  margin: EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                      color: _status == "ACTIVE"
                          ? AppStyles.primaryRed
                          : _status == "RESOLVED"
                              ? AppStyles.primaryTeal
                              : AppStyles.mediumGray,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    _status,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.pureWhite),
                  ),
                ),
              ]),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppStyles.pureWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  AppStyles()
                      .lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))
                ],
              ),
              padding: widget.report.type != 'POST'
                  ? EdgeInsets.all(16)
                  : EdgeInsets.zero,
              child: reportContent != null
                  ? widget.report.type == 'POST'
                      ? PostProvider(
                          key: ValueKey(reportContent.postId + "Preview"),
                          post: reportContent,
                          isPreview: true,
                        )
                      : widget.report.type == 'COMMENT'
                          ? CommentProvider(
                              key:
                                  ValueKey(reportContent.commentId + "Preview"),
                              comment: reportContent,
                              isPreview: true,
                            )
                          : ReplyProvider(
                              key: ValueKey(reportContent.replyId + "Preview"),
                              reply: reportContent,
                              onReplyTap: (userName, userId, postId, commentId,
                                  replyId) {},
                              isPreview: true,
                            )
                  : Container(),
            )
          ],
        ));
  }
}

class UserRequestContainer extends StatefulWidget {
  const UserRequestContainer({
    super.key,
    required this.userRequest,
    required this.user,
    required this.timestamp,
    this.onApprove,
    this.onDecline,
  });

  final UserRequestModel userRequest;
  final UserModel user;
  final String timestamp;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  @override
  State<UserRequestContainer> createState() => _UserRequestContainerState();
}

class _UserRequestContainerState extends State<UserRequestContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            margin: EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Icon(
                  widget.userRequest.type == 'ADMIN'
                      ? Icons.verified_user_outlined
                      : Icons.verified_outlined,
                  size: 40,
                  color: AppStyles.primaryTeal,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    margin: EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppStyles.pureWhite,
                      boxShadow: [
                        AppStyles().lightBoxShadow(
                            AppStyles.primaryBlack.withAlpha(150))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: widget.user.profileURL != ''
                        ? Container(
                            height: 16,
                            width: 16,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Opacity(
                              opacity: 1,
                              child: AppRoundedImage(
                                imageType: ImageType.network,
                                image: widget.user.profileURL,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.account_circle_outlined,
                            size: 18,
                            color: AppStyles.primaryTealLighter,
                          ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
                width: double.infinity,
                child: Text.rich(
                  TextSpan(children: [
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              Get.toNamed("/profile/" + widget.user.userName),
                          child: Text(widget.user.userName,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppStyles.primaryTeal)),
                        ),
                      ),
                    ),
                    TextSpan(
                        text:
                            " requested for ${widget.userRequest.type == "ADMIN" ? "admin access." : "account verification."}"),
                    TextSpan(
                        text: "  ${widget.timestamp}",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            color: AppStyles.lightGrey)),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppStyles.primaryBlack, height: 1),
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            height: 32,
            width: 32,
            child: MaterialButtonIcon(
              onTap: () async {
                if (widget.onApprove != null) widget.onApprove!();
              },
              withIcon: true,
              withText: false,
              icon: Icons.check,
              buttonColor: AppStyles.primaryGreen,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            height: 32,
            width: 32,
            child: MaterialButtonIcon(
              onTap: () {
                if (widget.onDecline != null) widget.onDecline!();
              },
              withIcon: true,
              withText: false,
              icon: Icons.close_rounded,
              buttonColor: AppStyles.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}

class UserRequestContainerShimmer extends StatelessWidget {
  const UserRequestContainerShimmer({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppStyles.pureWhite, borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            margin: EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppShimmerEffect(
                    width: double.infinity,
                    height: double.infinity,
                    radius: 0,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    margin: EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppShimmerEffect(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppShimmerEffect(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppShimmerEffect(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppShimmerEffect(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeContainerShimmer extends StatelessWidget {
  const BadgeContainerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppStyles.pureWhite,
          boxShadow: [
            AppStyles().lightBoxShadow(AppStyles.primaryTeal.withAlpha(120))
          ],
        ),
        padding: EdgeInsets.all(16),
        height: 80,
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppShimmerEffect(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppStyles.bgGrey,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppShimmerEffect(
                        width: double.infinity,
                        height: double.infinity,
                        radius: 0,
                      )),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppStyles.bgGrey,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppShimmerEffect(
                        width: double.infinity,
                        height: double.infinity,
                        radius: 0,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeContainer extends StatelessWidget {
  const BadgeContainer({
    super.key,
    required this.badge,
    this.onTap,
  });

  final BadgeModel badge;
  final Function(BadgeModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppStyles.pureWhite,
        elevation: 10,
        shadowColor: AppStyles.primaryTeal.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onTap != null) {
              onTap!(badge);
            }
          },
          hoverColor: AppStyles.primaryTealLightest,
          splashColor: AppStyles.lightGrey.withAlpha(50),
          highlightColor: AppStyles.lightGrey.withAlpha(50),
          child: Ink(
            child: Container(
              padding: EdgeInsets.all(16),
              height: 80,
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: badge.tier == 'BRONZE'
                          ? AppStyles.primaryBronze
                          : badge.tier == 'SILVER'
                              ? AppStyles.primarySilver
                              : badge.tier == 'GOLD'
                                  ? AppStyles.primaryGold
                                  : badge.tier == 'PLATINUM'
                                      ? AppStyles.primaryPlatinum
                                      : badge.tier == 'DIAMOND'
                                          ? AppStyles.primaryDiamond
                                          : AppStyles.primaryTeal,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppStyles.pureWhite,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (badge.badgeIconUrl == '')
                          ? Icon(Icons.auto_awesome,
                              color: badge.tier == 'BRONZE'
                                  ? AppStyles.primaryBronze
                                  : badge.tier == 'SILVER'
                                      ? AppStyles.primarySilver
                                      : badge.tier == 'GOLD'
                                          ? AppStyles.primaryGold
                                          : badge.tier == 'PLATINUM'
                                              ? AppStyles.primaryPlatinum
                                              : badge.tier == 'DIAMOND'
                                                  ? AppStyles.primaryDiamond
                                                  : AppStyles.primaryTeal,
                              size: 30)
                          : AppRoundedImage(
                              imageType: ImageType.network,
                              image: badge.badgeIconUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${badge.badgeTitle}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: AppStyles.muteBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
