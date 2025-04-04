import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/main.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          constraints: BoxConstraints(maxWidth: 300),
          height: double.infinity,
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: SideBar(
                    isMobile: true,
                    constraints: constraints,
                    activeMenu: 5,
                    onPost: (post) {
                      Get.toNamed('/post/${post.postId}');
                    }),
              ),
            );
          }),
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: AppStyles.bgGrey,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _buildFullContainers(constraints, size);
          },
        ),
      ),
    );
  }

  Widget _buildFullContainers(BoxConstraints constraints, Size size) {
    RxBool requestSent = false.obs;
    return Container(
      width: constraints.maxWidth,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (constraints.maxWidth / constraints.maxHeight > 0.8)
                  Container(
                    alignment: Alignment.topRight,
                    width: (constraints.maxWidth >= AppConstants.navbarBreakpoint) ? AppConstants.navbarWidth : 100,
                    margin: EdgeInsets.only(right: 20),
                    padding: (constraints.maxWidth >= AppConstants.navbarBreakpoint)
                        ? EdgeInsets.fromLTRB(60, 30, 0, 30)
                        : EdgeInsets.fromLTRB(40, 30, 0, 30),
                    child: SideBar(
                        constraints: constraints,
                        activeMenu: 5,
                        onPost: (post) {
                          Get.toNamed('/post/${post.postId}');
                        }),
                  ),
                Flexible(
                    child: Container(
                  constraints: (constraints.maxWidth >= AppConstants.sidebarBreakpoint)
                      ? BoxConstraints(maxWidth: AppConstants.bodyMaxWidth)
                      : null,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: (constraints.maxWidth / constraints.maxHeight > 0.8) ? 90 : 70,
                        decoration: BoxDecoration(color: AppStyles.bgGrey),
                        alignment: Alignment.bottomCenter,
                        padding: (constraints.maxWidth / constraints.maxHeight > 0.8)
                            ? EdgeInsets.only(left: 40, right: 40)
                            : EdgeInsets.only(right: 20),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                          padding: EdgeInsets.only(bottom: 8, left: 16),
                          child: Row(
                            children: [
                              if (constraints.maxWidth / constraints.maxHeight <= 0.8)
                                Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: IconButton(
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                        icon: Icon(
                                          Icons.menu_rounded,
                                          size: 30,
                                          color: AppStyles.primaryTealLighter,
                                        ))),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    "Settings",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        color: AppStyles.primaryTealLighter,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        height: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 50),
                            child: Container(
                              padding: (constraints.maxWidth / constraints.maxHeight > 0.8)
                                  ? EdgeInsets.fromLTRB(40, 10, 40, 10)
                                  : EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                children: [
                                  Obx(() => (AuthenticationRepository.instance.currentUserModel.value != null)
                                      ? UserProfileContainer(
                                          userModel: AuthenticationRepository.instance.currentUserModel.value!,
                                          uid: AuthenticationRepository.instance.currentUserModel.value!.uid,
                                          userProfileURL:
                                              AuthenticationRepository.instance.currentUserModel.value!.profileURL,
                                          username: AuthenticationRepository.instance.currentUserModel.value!.userName,
                                          bio: AuthenticationRepository.instance.currentUserModel.value!.bio,
                                          location: AuthenticationRepository.instance.currentUserModel.value!.location,
                                          fullName: AuthenticationRepository.instance.currentUserModel.value!.name,
                                          email: AuthenticationRepository.instance.currentUserModel.value!.email,
                                          phone: AuthenticationRepository.instance.currentUserModel.value!.phone,
                                          isEmailPublic:
                                              AuthenticationRepository.instance.currentUserModel.value!.isEmailPublic,
                                          isPhonePublic:
                                              AuthenticationRepository.instance.currentUserModel.value!.isPhonePublic,
                                          isLocationPublic: AuthenticationRepository
                                              .instance.currentUserModel.value!.isLocationPublic,
                                          isFullNamePublic:
                                              AuthenticationRepository.instance.currentUserModel.value!.isNamePublic,
                                          isVerified:
                                              AuthenticationRepository.instance.currentUserModel.value!.isVerified,
                                        )
                                      : Container()),
                                  Obx(() => (AuthenticationRepository.instance.currentUserModel.value != null &&
                                              !AuthenticationRepository.instance.currentUserModel.value!.isVerified) ||
                                          requestSent.value
                                      ? SettingsOptionContainer(
                                          title: "Request for verified account",
                                          icon: Icons.verified_rounded,
                                          end: null,
                                          onClick: () async {
                                            final isConnected = await NetworkManager.instance.isConnected();
                                            if (!isConnected) {
                                              AppPopups.customToast(message: 'No Internet Connection');
                                              return;
                                            }
                                            try {
                                              bool isSent = await DatabaseRepository.instance.checkIfRequestExists(
                                                  uid: AuthenticationRepository.instance.currentUserModel.value!.uid,
                                                  type: "VERIFIED");
                                              if (isSent) {
                                                AppPopups.warningSnackBar(
                                                  title: "InFound",
                                                  message: "You have already sent a request for a verified account",
                                                );
                                                return;
                                              } else {
                                                UserRequestModel request = UserRequestModel(
                                                    requestId: uuid.v1(),
                                                    uid: AuthenticationRepository.instance.currentUserModel.value!.uid,
                                                    type: "VERIFIED",
                                                    updatedAt: DateTime.now(),
                                                    createdAt: DateTime.now());
                                                await DatabaseRepository.instance.createUserRequest(request: request);
                                              }
                                            } catch (e) {
                                              AppPopups.customToast(message: 'An error occurred. Please try again.');
                                              return;
                                            }
                                          },
                                        )
                                      : Container()),
                                  SettingsOptionContainer(
                                    title: "Privacy options",
                                    icon: Icons.privacy_tip_rounded,
                                    end: null,
                                    onClick: () {
                                      AppPopups.openPrivacyOptions();
                                    },
                                  ),
                                  // SettingsOptionContainer(title: "Dark mode", icon: Icons.dark_mode_rounded, end: null),
                                  SettingsOptionContainer(
                                    title: "User guidelines",
                                    icon: Icons.info,
                                    end: null,
                                    onClick: () {
                                      AppPopups.openUserGuidelines();
                                    },
                                  ),
                                  SettingsOptionContainer(
                                      onClick: () {
                                        AppPopups.openAboutPopup();
                                      },
                                      title: "About InFound",
                                      icon: Icons.not_listed_location_rounded,
                                      end: null),
                                  SettingsOptionContainer(
                                      onClick: () async {
                                        if (AuthenticationRepository.instance.currentUserModel.value != null) {
                                          AppPopups.openDeleteAccountDialog(context: context);
                                        }
                                      },
                                      title: "Delete account and data",
                                      icon: Icons.delete_forever_rounded,
                                      end: null),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
                (constraints.maxWidth / constraints.maxHeight > 0.8)
                    ? (constraints.maxWidth >= AppConstants.sidebarBreakpoint)
                        ? Container(
                            width: AppConstants.sidebarWidth,
                            margin: EdgeInsets.only(left: 20),
                            padding: EdgeInsets.fromLTRB(0, 30, 60, 30),
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                // SearchBox(),
                              ],
                            ),
                          )
                        : Container()
                    : Container()
              ],
            ),
          );
        },
      ),
    );
  }
}

class SettingsOptionContainer extends StatelessWidget {
  const SettingsOptionContainer({
    super.key,
    required this.title,
    required this.icon,
    this.end,
    this.onClick,
  });

  final String title;
  final IconData icon;
  final Widget? end;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
      child: Material(
        color: AppStyles.pureWhite,
        elevation: 10,
        shadowColor: AppStyles.primaryTeal.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onClick != null) onClick!();
          },
          hoverColor: AppStyles.primaryTealDarker.withAlpha(30),
          splashColor: AppStyles.primaryTealDarker.withAlpha(50),
          highlightColor: AppStyles.primaryTealDarker.withAlpha(50),
          child: Ink(
            child: Container(
              padding: EdgeInsets.all(16),
              height: 80,
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    child: Icon(
                      icon,
                      color: AppStyles.lightGrey,
                      size: 38,
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
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppStyles.primaryBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                      height: 48,
                      width: 48,
                      child: (end != null)
                          ? end
                          : Icon(Icons.arrow_outward_rounded, color: AppStyles.lightGrey, size: 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
