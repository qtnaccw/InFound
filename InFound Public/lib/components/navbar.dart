import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  SideBar(
      {super.key, required this.constraints, required this.onPost, required this.activeMenu, this.isMobile = false});

  final BoxConstraints constraints;
  final int activeMenu;
  final Function(PostModel) onPost;
  final bool isMobile;

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  RxBool isDoneLoading = false.obs;

  @override
  void initState() {
    super.initState();
    waitForValue<bool?>(() => AuthenticationRepository.instance.loadUserDone.value, timeout: Duration(seconds: 5))
        .then((val) {
      isDoneLoading.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Obx(
        () => isDoneLoading.value
            ? Column(
                children: [
                  Container(
                    height: 36,
                    width: widget.constraints.maxWidth,
                    margin: EdgeInsets.only(bottom: 16),
                    child: SvgPicture.asset(
                      (widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile)
                          ? AppConstants.iAppIconFullColored
                          : AppConstants.iAppIconSimpleColored,
                      alignment: (widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile)
                          ? Alignment.topLeft
                          : Alignment.topCenter,
                    ),
                  ),
                  Container(
                    height: 48,
                    margin: EdgeInsets.only(bottom: 16),
                    child: AuthenticationRepository.instance.currentUserModel.value == null
                        ? MaterialButtonIcon(
                            onTap: () {
                              Get.toNamed(AppRoutes.login);
                            },
                            text: 'Login to InFound',
                            withIcon: true,
                            withText: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile,
                            iconPadding: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile
                                ? EdgeInsets.only(right: 12)
                                : null,
                            icon: Icons.login,
                            buttonColor: AppStyles.primaryTeal,
                            highlightColor: AppStyles.primaryTealDarker,
                            splashColor: AppStyles.primaryTealDarkest,
                          )
                        : Row(
                            mainAxisAlignment:
                                (widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile)
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 6),
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: AppStyles.pureWhite,
                                  boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
                                ),
                                alignment: Alignment.center,
                                child: AuthenticationRepository.instance.currentUserModel.value!.profileURL != ''
                                    ? Container(
                                        height: 38,
                                        width: 38,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: AppRoundedImage(
                                          imageType: ImageType.network,
                                          image: AuthenticationRepository.instance.currentUserModel.value!.profileURL,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.account_circle_outlined,
                                        size: 46,
                                        color: AppStyles.primaryTealLighter,
                                      ),
                              ),
                              (widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile)
                                  ? Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Hi, ${AuthenticationRepository.instance.currentUserModel.value!.userName}',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 20,
                                                          color: AppStyles.primaryTealDarkest,
                                                          height: 1.2),
                                                    ),
                                                  ),
                                                  if (AuthenticationRepository
                                                      .instance.currentUserModel.value!.isVerified)
                                                    Padding(
                                                        padding: EdgeInsets.only(left: 3),
                                                        child: Icon(
                                                          Icons.verified,
                                                          color: AppStyles.primaryTeal,
                                                          size: 20,
                                                        ))
                                                ],
                                              ),
                                            ),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  if (widget.isMobile) Scaffold.of(context).closeDrawer();
                                                  logout(context);
                                                },
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                        padding: EdgeInsets.only(right: 4),
                                                        child: Icon(
                                                          Icons.logout,
                                                          size: 12,
                                                          color: AppStyles.primaryTeal,
                                                        )),
                                                    Text(
                                                      'Logout',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 12,
                                                          color: AppStyles.primaryTeal,
                                                          height: 1.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                  ),
                  if (AuthenticationRepository.instance.currentUserModel.value != null)
                    Container(
                        height: 48,
                        width: widget.constraints.maxWidth,
                        margin: EdgeInsets.only(bottom: 16),
                        child: MaterialButtonIcon(
                          onTap: () async {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (AuthenticationRepository.instance.currentUserModel.value != null) {
                                if (widget.isMobile) Scaffold.of(context).closeDrawer();
                                AppPopups.openComposeBox(
                                    username: AuthenticationRepository.instance.currentUserModel.value!.userName,
                                    uid: AuthenticationRepository.instance.currentUserModel.value!.uid,
                                    profileURL: AuthenticationRepository.instance.currentUserModel.value!.profileURL,
                                    isVerified: AuthenticationRepository.instance.currentUserModel.value!.isVerified,
                                    isEditing: false,
                                    onPost: widget.onPost);
                              }
                            });
                            // AppPopups.openBadgeGrantRevoke(
                            //     badge: BadgeModel(
                            //         badgeId: "Sample",
                            //         badgeTitle: "Sample",
                            //         badgeDescription: "Smaple",
                            //         badgeIconUrl: "",
                            //         badgeCondition: "",
                            //         tier: "Silver",
                            //         badgeOwners: [],
                            //         updatedAt: DateTime.now(),
                            //         createdAt: DateTime.now()));
                          },
                          text: 'Create a post',
                          withIcon: true,
                          withText: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile,
                          iconPadding: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile
                              ? EdgeInsets.only(right: 12)
                              : null,
                          icon: Icons.edit_note,
                          buttonColor: AppStyles.primaryTeal,
                          highlightColor: AppStyles.primaryTealDarker,
                          splashColor: AppStyles.primaryTealDarkest,
                        )),
                  MenuOption(
                    isMobile: widget.isMobile,
                    constraints: widget.constraints,
                    isActive: widget.activeMenu == 0,
                    title: "Home",
                    icon: Icons.home_outlined,
                    iconActive: Icons.home,
                    onTap: () {
                      if (widget.isMobile) Scaffold.of(context).closeDrawer();
                      Get.toNamed('/');
                    },
                  ),
                  if (widget.constraints.maxWidth < AppConstants.sidebarBreakpoint)
                    MenuOption(
                      isMobile: widget.isMobile,
                      constraints: widget.constraints,
                      isActive: widget.activeMenu == 6,
                      title: "Search",
                      icon: Icons.search_rounded,
                      iconActive: Icons.search_rounded,
                      onTap: () {
                        if (widget.isMobile) Scaffold.of(context).closeDrawer();
                        Get.toNamed(AppRoutes.search);
                      },
                    ),
                  MenuOption(
                    isMobile: widget.isMobile,
                    constraints: widget.constraints,
                    isActive: widget.activeMenu == 1,
                    title: "Profile",
                    icon: Icons.account_circle_outlined,
                    iconActive: Icons.account_circle,
                    onTap: () {
                      if (widget.isMobile) Scaffold.of(context).closeDrawer();
                      if (AuthenticationRepository.instance.currentUserModel.value != null) {
                        Get.toNamed('/profile/${AuthenticationRepository.instance.currentUserModel.value!.userName}',
                            arguments: {'fromNavbar': true});
                      } else {
                        Get.toNamed(AppRoutes.login);
                      }
                    },
                  ),
                  MenuOption(
                    isMobile: widget.isMobile,
                    constraints: widget.constraints,
                    isActive: widget.activeMenu == 2,
                    title: "Notifications",
                    icon: Icons.notifications_active_outlined,
                    iconActive: Icons.notifications_active_rounded,
                    onTap: () {
                      if (widget.isMobile) Scaffold.of(context).closeDrawer();
                      if (AuthenticationRepository.instance.currentUserModel.value != null) {
                        Get.toNamed(AppRoutes.notifications);
                      } else {
                        Get.toNamed(AppRoutes.login);
                      }
                    },
                  ),
                  MenuOption(
                    isMobile: widget.isMobile,
                    constraints: widget.constraints,
                    isActive: widget.activeMenu == 3,
                    title: "Bookmarks",
                    icon: Icons.bookmark_outline,
                    iconActive: Icons.bookmark_rounded,
                    onTap: () {
                      if (widget.isMobile) Scaffold.of(context).closeDrawer();
                      if (AuthenticationRepository.instance.currentUserModel.value != null) {
                        Get.toNamed(AppRoutes.bookmarks);
                      } else {
                        Get.toNamed(AppRoutes.login);
                      }
                    },
                  ),
                  if (AuthenticationRepository.instance.currentUserModel.value != null &&
                      AuthenticationRepository.instance.currentUserModel.value!.isAdmin)
                    MenuOption(
                      isMobile: widget.isMobile,
                      constraints: widget.constraints,
                      isActive: widget.activeMenu == 4,
                      title: "Admin Dashboard",
                      icon: Icons.admin_panel_settings_outlined,
                      iconActive: Icons.admin_panel_settings,
                      onTap: () {
                        if (widget.isMobile) Scaffold.of(context).closeDrawer();
                        if (AuthenticationRepository.instance.currentUserModel.value != null &&
                            AuthenticationRepository.instance.currentUserModel.value!.isAdmin) {
                          Get.toNamed(AppRoutes.admin);
                        } else {
                          Get.toNamed(AppRoutes.home);
                        }
                      },
                    ),
                  MenuOption(
                    isMobile: widget.isMobile,
                    constraints: widget.constraints,
                    isActive: widget.activeMenu == 5,
                    title: "Settings",
                    icon: Icons.settings_outlined,
                    iconActive: Icons.settings,
                    onTap: () {
                      if (widget.isMobile) Scaffold.of(context).closeDrawer();
                      if (AuthenticationRepository.instance.currentUserModel.value != null) {
                        Get.toNamed(AppRoutes.settings);
                      } else {
                        Get.toNamed(AppRoutes.login);
                      }
                    },
                  ),
                  if (AuthenticationRepository.instance.currentUserModel.value != null &&
                      (widget.constraints.maxWidth < AppConstants.navbarBreakpoint || widget.isMobile))
                    Container(
                        height: 48,
                        width: widget.constraints.maxWidth,
                        margin: EdgeInsets.only(top: 16),
                        child: MaterialButtonIcon(
                          onTap: () async {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (widget.isMobile) Scaffold.of(context).closeDrawer();
                              if (AuthenticationRepository.instance.currentUserModel.value != null) {
                                logout(context);
                              }
                            });
                          },
                          text: 'Logout',
                          withIcon: true,
                          withText: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile,
                          iconPadding: widget.constraints.maxWidth >= AppConstants.navbarBreakpoint || widget.isMobile
                              ? EdgeInsets.only(right: 12)
                              : null,
                          icon: Icons.logout_rounded,
                          iconColor: AppStyles.primaryRed,
                          fontColor: AppStyles.primaryRed,
                          buttonColor: Colors.transparent,
                          buttonPadding: EdgeInsets.all(4),
                          highlightColor: AppStyles.primaryRed.withOpacity(0.2),
                          splashColor: AppStyles.primaryRed.withOpacity(0.3),
                        )),
                ],
              )
            : Container(
                height: widget.constraints.maxHeight,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  void logout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        AppPopups.customToast(message: 'No Internet Connection');
        return;
      }
      AppPopups.openLoadingDialog("Logging you out...", AppConstants.aInFoundLoader);
      try {
        AuthenticationRepository.instance.signOut();
        Provider.of<NotificationService>(context, listen: false).stopListening();
        await Future.delayed(Duration(seconds: 3)).then((onValue) {
          AppPopups.closeDialog();
          Get.offAllNamed(AppRoutes.home);
        });
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.customToast(message: 'An error occurred. Please try again.');
      }
    });
  }
}

// Widget sideBarNavDesktop(BoxConstraints constraints, int activeMenu,
//     {required Function(PostModel) onPost, required BuildContext context}) {
//   return Container(
//     width: double.infinity,
//     child: Obx(
//       () => Column(
//         children: [
//           Container(
//             height: 36,
//             width: constraints.maxWidth,
//             margin: EdgeInsets.only(bottom: 20),
//             child: SvgPicture.asset(
//               (constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile) ? AppConstants.iAppIconFullColored : AppConstants.iAppIconSimpleColored,
//               alignment: (constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile) ? Alignment.topLeft : Alignment.topCenter,
//             ),
//           ),
//           Container(
//             height: 48,
//             margin: EdgeInsets.only(bottom: 20),
//             child: AuthenticationRepository.instance.currentUserModel.value == null
//                 ? MaterialButtonIcon(
//                     onTap: () {
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         context.visitChildElements((element) {
//                           Get.toNamed(AppRoutes.login);
//                         });
//                       });
//                     },
//                     text: 'Login to InFound',
//                     withIcon: true,
//                     withText: constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile,
//                     iconPadding: constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile ? EdgeInsets.only(right: 12) : null,
//                     icon: Icons.login,
//                     buttonColor: AppStyles.primaryTeal,
//                     highlightColor: AppStyles.primaryTealDarker,
//                     splashColor: AppStyles.primaryTealDarkest,
//                   )
//                 : Row(
//                     mainAxisAlignment:
//                         (constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.only(right: 6),
//                         height: 48,
//                         width: 48,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(50),
//                           color: AppStyles.pureWhite,
//                           boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))],
//                         ),
//                         alignment: Alignment.center,
//                         child: AuthenticationRepository.instance.currentUserModel.value!.profileURL != ''
//                             ? Container(
//                                 height: 38,
//                                 width: 38,
//                                 clipBehavior: Clip.antiAlias,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: AppRoundedImage(
//                                   imageType: ImageType.network,
//                                   image: AuthenticationRepository.instance.currentUserModel.value!.profileURL,
//                                   fit: BoxFit.cover,
//                                 ),
//                               )
//                             : Icon(
//                                 Icons.account_circle_outlined,
//                                 size: 46,
//                                 color: AppStyles.primaryTealLighter,
//                               ),
//                       ),
//                       (constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile)
//                           ? Expanded(
//                               child: Container(
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: double.infinity,
//                                       child: Row(
//                                         children: [
//                                           Flexible(
//                                             child: Text(
//                                               'Hi, ${AuthenticationRepository.instance.currentUserModel.value!.userName}',
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                               style: GoogleFonts.poppins(
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 20,
//                                                   color: AppStyles.primaryTealDarkest,
//                                                   height: 1.2),
//                                             ),
//                                           ),
//                                           if (AuthenticationRepository.instance.currentUserModel.value!.isVerified)
//                                             Padding(
//                                                 padding: EdgeInsets.only(left: 3),
//                                                 child: Icon(
//                                                   Icons.verified,
//                                                   color: AppStyles.primaryTeal,
//                                                   size: 20,
//                                                 ))
//                                         ],
//                                       ),
//                                     ),
//                                     MouseRegion(
//                                       cursor: SystemMouseCursors.click,
//                                       child: GestureDetector(
//                                         onTap: () async {
//                                           WidgetsBinding.instance.addPostFrameCallback((_) async {
//                                             final isConnected = await NetworkManager.instance.isConnected();
//                                             if (!isConnected) {
//                                               AppPopups.customToast(message: 'No Internet Connection');
//                                               return;
//                                             }
//                                             AppPopups.openLoadingDialog(
//                                                 "Logging you out...", AppConstants.aInFoundLoader);
//                                             try {
//                                               AuthenticationRepository.instance.signOut();
//                                               await Future.delayed(Duration(seconds: 3)).then((onValue) {
//                                                 AppPopups.closeDialog();
//                                                 Get.offAllNamed(AppRoutes.home);
//                                               });
//                                             } catch (e) {
//                                               AppPopups.closeDialog();
//                                               AppPopups.customToast(message: 'An error occurred. Please try again.');
//                                             }
//                                           });
//                                         },
//                                         child: Row(
//                                           children: [
//                                             Padding(
//                                                 padding: EdgeInsets.only(right: 4),
//                                                 child: Icon(
//                                                   Icons.logout,
//                                                   size: 12,
//                                                   color: AppStyles.primaryTeal,
//                                                 )),
//                                             Text(
//                                               'Logout',
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                               style: GoogleFonts.poppins(
//                                                   fontWeight: FontWeight.w400,
//                                                   fontSize: 12,
//                                                   color: AppStyles.primaryTeal,
//                                                   height: 1.5),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : Container(),
//                     ],
//                   ),
//           ),
//           if (AuthenticationRepository.instance.currentUserModel.value != null)
//             Container(
//                 height: 48,
//                 width: constraints.maxWidth,
//                 margin: EdgeInsets.only(bottom: 20),
//                 child: MaterialButtonIcon(
//                   onTap: () async {
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (AuthenticationRepository.instance.currentUserModel.value != null) {
//                         AppPopups.openComposeBox(
//                             username: AuthenticationRepository.instance.currentUserModel.value!.userName,
//                             uid: AuthenticationRepository.instance.currentUserModel.value!.uid,
//                             profileURL: AuthenticationRepository.instance.currentUserModel.value!.profileURL,
//                             isVerified: AuthenticationRepository.instance.currentUserModel.value!.isVerified,
//                             isEditing: false,
//                             onPost: onPost);
//                       }
//                     });
//                   },
//                   text: 'Create a post',
//                   withIcon: true,
//                   withText: constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile,
//                   iconPadding: constraints.maxWidth >=  AppConstants.navbarBreakpoint || widget.isMobile ? EdgeInsets.only(right: 12) : null,
//                   icon: Icons.edit_note,
//                   buttonColor: AppStyles.primaryTeal,
//                   highlightColor: AppStyles.primaryTealDarker,
//                   splashColor: AppStyles.primaryTealDarkest,
//                 )),
//           ...menus(constraints, activeMenu)
//         ],
//       ),
//     ),
//   );
// }

// RxList<Widget> menus(BoxConstraints constraints, int active) {
//   return RxList<Widget>([
//     MenuOption(isMobile: widget.isMobile,
//       constraints: constraints,
//       isActive: active == 0,
//       title: "Home",
//       icon: Icons.home_outlined,
//       iconActive: Icons.home,
//       onTap: () {
//         Get.toNamed('/');
//       },
//     ),
//     MenuOption(isMobile: widget.isMobile,
//       constraints: constraints,
//       isActive: active == 1,
//       title: "Profile",
//       icon: Icons.account_circle_outlined,
//       iconActive: Icons.account_circle,
//       onTap: () {
//         if (AuthenticationRepository.instance.currentUserModel.value != null) {
//           Get.toNamed('/profile/${AuthenticationRepository.instance.currentUserModel.value!.userName}');
//         } else {
//           Get.toNamed(AppRoutes.login);
//         }
//       },
//     ),
//     MenuOption(isMobile: widget.isMobile,
//       constraints: constraints,
//       isActive: active == 2,
//       title: "Notifications",
//       icon: Icons.notifications_active_outlined,
//       iconActive: Icons.notifications_active_rounded,
//       onTap: () {
//         if (AuthenticationRepository.instance.currentUserModel.value != null) {
//           Get.toNamed(AppRoutes.notifications);
//         } else {
//           Get.toNamed(AppRoutes.login);
//         }
//       },
//     ),
//     MenuOption(isMobile: widget.isMobile,
//       constraints: constraints,
//       isActive: active == 3,
//       title: "Bookmarks",
//       icon: Icons.bookmark_outline,
//       iconActive: Icons.bookmark_rounded,
//       onTap: () {
//         if (AuthenticationRepository.instance.currentUserModel.value != null) {
//           Get.toNamed(AppRoutes.bookmarks);
//         } else {
//           Get.toNamed(AppRoutes.login);
//         }
//       },
//     ),
//     if (AuthenticationRepository.instance.currentUserModel.value != null &&
//         AuthenticationRepository.instance.currentUserModel.value!.isAdmin)
//       MenuOption(isMobile: widget.isMobile,
//         constraints: constraints,
//         isActive: active == 4,
//         title: "Admin Dashboard",
//         icon: Icons.admin_panel_settings_outlined,
//         iconActive: Icons.admin_panel_settings,
//         onTap: () {
//           if (AuthenticationRepository.instance.currentUserModel.value != null &&
//               AuthenticationRepository.instance.currentUserModel.value!.isAdmin) {
//             Get.toNamed(AppRoutes.admin);
//           } else {
//             Get.toNamed(AppRoutes.home);
//           }
//         },
//       ),
//     MenuOption(isMobile: widget.isMobile,
//       constraints: constraints,
//       isActive: active == 5,
//       title: "Settings",
//       icon: Icons.settings_outlined,
//       iconActive: Icons.settings,
//       onTap: () {
//         if (AuthenticationRepository.instance.currentUserModel.value != null) {
//           Get.toNamed(AppRoutes.settings);
//         } else {
//           Get.toNamed(AppRoutes.login);
//         }
//       },
//     ),
//   ]);
// }
