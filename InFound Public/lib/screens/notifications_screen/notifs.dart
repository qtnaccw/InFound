import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/notification_model.dart';
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

class NotificationsScreen1 extends StatefulWidget {
  NotificationsScreen1({super.key});

  @override
  State<NotificationsScreen1> createState() => _NotificationsScreen1State();
}

class _NotificationsScreen1State extends State<NotificationsScreen1> {
  ScrollController _scrollController = ScrollController();
  List<NotificationModel> notifs = [];
  bool hasNext = true;
  bool isFetching = false;
  bool fetchDone = false;

  int get unreadCount => notifs.where((n) => !n.read).length;

  Future getNotifications({DateTime? startAfter, int? limit}) async {
    if (isFetching) return;
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    if (hasNext && !isFetching) {
      if (mounted)
        setState(() {
          isFetching = true;
        });

      try {
        List<NotificationModel> temp = await DatabaseRepository.instance.getAllNotificationsByUser(
            userId: AuthenticationRepository.instance.currentUserModel.value?.uid ?? '',
            limit: limit ?? AppConstants.nLimitNotifications,
            startAfter: startAfter);
        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitPosts) || temp.length == 0) hasNext = false;
            notifs.addAll(temp);
            isFetching = false;
            fetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(message: 'An error occurred. Please reload the page and try again.');
        if (mounted)
          setState(() {
            isFetching = false;
          });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      waitForValue<List<String>>(() => AuthenticationRepository.instance.currentUserModel.value?.bookmarks,
              timeout: Duration(seconds: 5))
          .then((val) async {
        if (val != null) {
          getNotifications();
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });

      _scrollController.addListener(() async {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent * 0.9 &&
            !_scrollController.position.outOfRange) {
          if (hasNext) {
            await getNotifications(startAfter: notifs.last.createdAt);
          }
        }
      });
    }
  }

  ValueKey listKey = ValueKey('listKey');

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
    return Container(
      width: constraints.maxWidth,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (constraints.maxWidth / constraints.maxHeight > 0.8)
                    ? Container(
                        alignment: Alignment.topCenter,
                        width: (constraints.maxWidth >= AppConstants.navbarBreakpoint) ? 320 : 100,
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
                        //     child: sideBarNavDesktop(constraints, 2, onPost: (post) {
                        //   Get.toNamed('/post/${post.postId}');
                        // }, context: context),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: (constraints.maxWidth / constraints.maxHeight > 0.8) ? 90 : 70,
                          decoration: BoxDecoration(color: AppStyles.bgGrey),
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                            padding: EdgeInsets.only(bottom: 8, left: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(
                                      'Notifications ${unreadCount > 0 ? '(${unreadCount})' : ''}',
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
                                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                child: Column(
                                  children: [
                                    fetchDone
                                        ? Container(
                                            constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                            child: Column(
                                              key: listKey,
                                              children: [
                                                for (NotificationModel notif in notifs)
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
                                                            if (mounted)
                                                              setState(() {
                                                                NotificationModel temp = notif.copyWith(read: true);
                                                                notifs[notifs.indexWhere((element) =>
                                                                    element.notifId == notif.notifId)] = temp;
                                                              });
                                                          });
                                                          final notificationService =
                                                              Provider.of<NotificationService>(context, listen: false);
                                                          notificationService.markAsRead(notif.notifId);
                                                        } catch (e) {
                                                          AppPopups.customToast(
                                                              message: 'An error occurred. Please try again.');
                                                        }
                                                      }
                                                      if (notif.type == 'USERREQUEST' || notif.type == 'BADGE') {
                                                        Get.toNamed('/profile/' +
                                                            AuthenticationRepository
                                                                .instance.currentUserModel.value!.userName);
                                                      } else {
                                                        Get.toNamed('/post/' + notif.postId);
                                                      }
                                                    },
                                                  ),
                                                hasNext
                                                    ? NotificationContainerShimmer()
                                                    : notifs.length != 0
                                                        ? EndOfResultContainer()
                                                        : NoResultContainer(),
                                              ],
                                            ),
                                          )
                                        : NotificationContainerShimmer(),
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
                    ? (constraints.maxWidth >= 1550)
                        ? Container(
                            width: AppConstants.sidebarWidth,
                            margin: EdgeInsets.only(left: 20),
                            padding: EdgeInsets.fromLTRB(0, 30, 60, 30),
                            alignment: Alignment.topCenter,
                            child: _sideBarRight(constraints),
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

  Widget _sideBarRight(BoxConstraints constraints) {
    return Column(
      children: [
        SearchBox(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppStyles.pureWhite,
          ),
          padding: EdgeInsets.fromLTRB(18, 24, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Actions',
                  style: GoogleFonts.poppins(
                      color: AppStyles.mediumGray, fontSize: 28, fontWeight: FontWeight.w700, height: 1),
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
                    if (notifs.length > 0) {
                      AppPopups.openLoadingDialog('Marking all notifications as read...', AppConstants.aInFoundLoader);
                      try {
                        await DatabaseRepository.instance.markAllNotificationsAsRead(
                            userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                        List<NotificationModel> tempList = [];
                        for (int i = 0; i < notifs.length; i++) {
                          NotificationModel newNotif = notifs[i].copyWith(read: true);
                          tempList.add(newNotif);
                        }
                        if (mounted)
                          setState(() {
                            notifs = tempList;
                            listKey = ValueKey('readAll');
                          });

                        AppPopups.closeDialog();
                        AppPopups.customToast(message: 'All notifications are marked as read.');
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
                    if (notifs.length > 0) {
                      AppPopups.openLoadingDialog(
                          'Marking all notifications as unread...', AppConstants.aInFoundLoader);
                      try {
                        await DatabaseRepository.instance.markAllNotificationsAsUnread(
                            userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                        int temp = await DatabaseRepository.instance.getNumUnreadNotificationsByUser(
                            userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                        List<NotificationModel> tempList = [];
                        for (int i = 0; i < notifs.length; i++) {
                          NotificationModel newNotif = notifs[i].copyWith(read: false);
                          tempList.add(newNotif);
                        }
                        if (mounted)
                          setState(() {
                            notifs.clear();
                            notifs.addAll(tempList);
                            listKey = ValueKey('unreadAll');
                          });

                        AppPopups.closeDialog();
                        AppPopups.customToast(message: 'All notifications are marked as unread.');
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
                    if (notifs.length > 0) {
                      AppPopups.openLoadingDialog('Clearing notifications list...', AppConstants.aInFoundLoader);
                      try {
                        await DatabaseRepository.instance
                            .clearNotifications(userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                        if (mounted)
                          setState(() {
                            notifs = [];
                            hasNext = false;
                            listKey = ValueKey('empty');
                          });
                        AppPopups.closeDialog();
                        AppPopups.customToast(message: 'Notifications list has been emptied.');
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
          ),
        ),
      ],
    );
  }
}
