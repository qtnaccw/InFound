import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/notification_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // bool isFirstRun = true;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (isFirstRun) {
  //     isFirstRun = false;
  //     notificationService = Provider.of<NotificationService>(context);
  //     notificationService.listenForNotifications();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      waitForValue<UserModel?>(() => AuthenticationRepository.instance.currentUserModel.value,
              timeout: Duration(seconds: 5))
          .then((val) {
        if (val != null) {
          // final notificationService = Provider.of<NotificationService>(context, listen: false);
          // notificationService.startListeningForNotificationsIfNeeded();
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var notificationService = Provider.of<NotificationService>(context, listen: false);
    notificationService.startListeningForNotificationsIfNeeded();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: size.width < AppConstants.sidebarBreakpoint
          ? Container(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () {
                  AppPopups.openScrollablePopup(
                      maxWidth: 500,
                      body: actionsPanel(
                          onClick: () {
                            AppPopups.closeDialog();
                          },
                          notificationService: notificationService),
                      footer: Container());
                },
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: AppStyles.pureWhite,
                ),
                extendedIconLabelSpacing: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                label: Text(
                  'Actions',
                  style: GoogleFonts.poppins(
                    color: AppStyles.pureWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppStyles.primaryTeal,
              ),
            )
          : null,
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
                    activeMenu: 2,
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
            return _buildFullContainers(constraints, size, notificationService);
          },
        ),
      ),
    );
  }

  Widget _buildFullContainers(BoxConstraints constraints, Size size, NotificationService notificationService) {
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
                        activeMenu: 2,
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
                                    child:
                                        Consumer<NotificationService>(builder: (context, notificationService, child) {
                                      return Text(
                                        'Notifications ${notificationService.notificationCount > 0 ? '(${notificationService.notificationCount})' : ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            color: AppStyles.primaryTealLighter,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            height: 1),
                                      );
                                    }),
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
                                    Container(
                                      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                      child:
                                          Consumer<NotificationService>(builder: (context, notificationService, child) {
                                        return Column(
                                          children: [
                                            for (NotificationModel notif in notificationService.notifications)
                                              NotificationProvider(
                                                notification: notif,
                                                onClick: () async {
                                                  final isConnected = await NetworkManager.instance.isConnected();
                                                  if (!isConnected) {
                                                    AppPopups.customToast(message: 'No Internet Connection');
                                                    return;
                                                  }
                                                  if (!notif.read) {
                                                    try {
                                                      notif = notif.copyWith(read: true);
                                                      await DatabaseRepository.instance
                                                          .updateNotification(notif: notif.copyWith(read: true))
                                                          .then((_) {
                                                        setState(() {
                                                          notificationService.markAsRead(notif.notifId);
                                                        });
                                                      });
                                                    } catch (e) {
                                                      printDebug(e);
                                                      AppPopups.customToast(
                                                          message: 'An error occurred. Please try again.');
                                                    }
                                                  }
                                                  if (notif.type == 'USERREQUEST') {
                                                    Get.toNamed('/profile/' +
                                                        AuthenticationRepository
                                                            .instance.currentUserModel.value!.userName);
                                                  } else if (notif.type == 'BADGE') {
                                                    BadgeModel? badge;
                                                    try {
                                                      badge = await DatabaseRepository.instance
                                                          .getBadgeById(badgeId: notif.targetId);
                                                    } catch (e) {
                                                      printDebug(e);
                                                      AppPopups.customToast(
                                                          message:
                                                              'An error occurred retrieving badge details. Please try again.');
                                                    }
                                                    if (badge != null) {
                                                      AppPopups.openBadgeView(context: context, badge: badge);
                                                    } else {
                                                      AppPopups.customToast(
                                                          message:
                                                              'Unable to retrieve badge. Badge could have been removed from the system.');
                                                    }
                                                  } else {
                                                    Get.toNamed('/post/' + notif.postId);
                                                  }
                                                },
                                              ),
                                            notificationService.notifications.length != 0
                                                ? EndOfResultContainer()
                                                : NoResultContainer(),
                                          ],
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                (constraints.maxWidth / constraints.maxHeight > 0.8)
                    ? (constraints.maxWidth >= AppConstants.sidebarBreakpoint)
                        ? Container(
                            width: AppConstants.sidebarWidth,
                            margin: EdgeInsets.only(left: 20),
                            padding: EdgeInsets.fromLTRB(0, 30, 60, 30),
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                SearchBox(),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppStyles.pureWhite,
                                  ),
                                  padding: EdgeInsets.fromLTRB(18, 24, 18, 24),
                                  child: actionsPanel(notificationService: notificationService),
                                ),
                              ],
                            ),
                          )
                        : Container()
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  Column actionsPanel({VoidCallback? onClick, required NotificationService notificationService}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Actions',
            style:
                GoogleFonts.poppins(color: AppStyles.mediumGray, fontSize: 28, fontWeight: FontWeight.w700, height: 1),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 1),
          padding: EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () async {
              final isConnected = await NetworkManager.instance.isConnected();
              if (!isConnected) {
                AppPopups.customToast(message: 'No Internet Connection');
                return;
              }
              if (notificationService.notifications.length > 0) {
                AppPopups.openLoadingDialog('Marking all notifications as read...', AppConstants.aInFoundLoader);
                try {
                  await DatabaseRepository.instance.markAllNotificationsAsRead(
                      userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                  setState(() {
                    notificationService.markAllAsRead();
                    if (onClick != null) onClick();
                  });
                  AppPopups.closeDialog();
                  AppPopups.customToast(message: 'All notifications are marked as read.');
                  Get.offAllNamed(AppRoutes.notifications);
                } catch (e) {
                  AppPopups.closeDialog();
                  AppPopups.customToast(
                      message: 'An error occurred while marking all notifications as read. Please try again.');
                }
              } else {
                AppPopups.customToast(message: 'Notifications list is empty.');
              }
            },
            child: Text(
              'Mark all as read',
              style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () async {
              final isConnected = await NetworkManager.instance.isConnected();
              if (!isConnected) {
                AppPopups.customToast(message: 'No Internet Connection');
                return;
              }
              if (notificationService.notifications.length > 0) {
                AppPopups.openLoadingDialog('Marking all notifications as unread...', AppConstants.aInFoundLoader);
                try {
                  await DatabaseRepository.instance.markAllNotificationsAsUnread(
                      userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                  setState(() {
                    notificationService.markAllAsUnread();
                    if (onClick != null) onClick();
                  });
                  AppPopups.closeDialog();
                  AppPopups.customToast(message: 'All notifications are marked as unread.');
                  Get.offAllNamed(AppRoutes.notifications);
                } catch (e) {
                  AppPopups.closeDialog();
                  AppPopups.customToast(
                      message: 'An error occurred while marking all notifications as unread. Please try again.');
                }
              } else {
                AppPopups.customToast(message: 'Notifications list is empty.');
              }
            },
            child: Text(
              'Mark all as unread',
              style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () async {
              final isConnected = await NetworkManager.instance.isConnected();
              if (!isConnected) {
                AppPopups.customToast(message: 'No Internet Connection');
                return;
              }
              if (notificationService.notifications.length > 0) {
                AppPopups.openLoadingDialog('Clearing notifications list...', AppConstants.aInFoundLoader);
                try {
                  await DatabaseRepository.instance
                      .clearNotifications(userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                  setState(() {
                    notificationService.deleteAllNotifications();
                    if (onClick != null) onClick();
                  });
                  AppPopups.closeDialog();
                  AppPopups.customToast(message: 'Notifications list has been emptied.');
                  Get.offAllNamed(AppRoutes.notifications);
                } catch (e) {
                  AppPopups.closeDialog();
                  AppPopups.customToast(
                      message: 'An error occurred while clearing notifications list. Please try again.');
                }
              } else {
                AppPopups.customToast(message: 'Notifications list is already empty.');
              }
            },
            child: Text(
              'Clear notifications list',
              style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1),
            ),
          ),
        ),
      ],
    );
  }
}
