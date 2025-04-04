import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/report_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  DateTime dateFrom = DateTime.now().subtract(Duration(days: 365));
  late TextEditingController dateInput;
  bool isAdmin = false;

  List<PostModel> posts = [];
  List<ReportModel> reports = [];
  List<BadgeModel> badges = [];
  List<UserRequestModel> userRequests = [];

  bool postsHasNext = true;
  bool postsIsFetching = false;
  bool postsFetchDone = false;

  bool reportsHasNext = true;
  bool reportsIsFetching = false;
  bool reportsFetchDone = false;

  bool badgesHasNext = true;
  bool badgesIsFetching = false;
  bool badgesFetchDone = false;

  bool userRequestsHasNext = true;
  bool userRequestsIsFetching = false;
  bool userRequestsFetchDone = false;

  Future getPosts({DateTime? startAfter, int? limit}) async {
    if (postsIsFetching) return;
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    if (postsHasNext && !postsIsFetching) {
      if (mounted)
        setState(() {
          postsIsFetching = true;
        });

      try {
        List<PostModel> temp = await DatabaseRepository.instance
            .getPostsOlderThan(
                date: dateFrom,
                limit: limit ?? AppConstants.nLimitPosts,
                startAfter: startAfter);

        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitPosts) ||
                temp.length == 0) postsHasNext = false;
            posts.addAll(temp);
            postsIsFetching = false;
            postsFetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(
            message: 'Error fetching posts. PLease reload page and try again.');
        if (mounted)
          setState(() {
            postsIsFetching = false;
          });
        return;
      }
    }
  }

  Future getReports({DateTime? startAfter, int? limit}) async {
    if (reportsIsFetching) return;
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    if (reportsHasNext && !reportsIsFetching) {
      if (mounted)
        setState(() {
          reportsIsFetching = true;
        });

      try {
        List<ReportModel> temp = await DatabaseRepository.instance
            .getAllReports(
                limit: limit ?? AppConstants.nLimitReports,
                startAfter: startAfter);

        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitReports) ||
                temp.length == 0) reportsHasNext = false;
            reports.addAll(temp);
            reportsIsFetching = false;
            reportsFetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(
            message:
                'Error fetching reports. PLease reload page and try again.');
        if (mounted)
          setState(() {
            reportsIsFetching = false;
          });
        return;
      }
    }
  }

  Future getBadges({DateTime? startAfter, int? limit}) async {
    if (badgesIsFetching) return;
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    if (badgesHasNext && !badgesIsFetching) {
      if (mounted)
        setState(() {
          badgesIsFetching = true;
        });

      try {
        List<BadgeModel> temp = await DatabaseRepository.instance.getAllBadges(
            limit: limit ?? AppConstants.nLimitBadges, startAfter: startAfter);
        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitBadges) ||
                temp.length == 0) badgesHasNext = false;
            badges.addAll(temp);
            badgesIsFetching = false;
            badgesFetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(
            message:
                'Error fetching badges. PLease reload page and try again.');
        if (mounted)
          setState(() {
            badgesIsFetching = false;
          });
        return;
      }
    }
  }

  Future getUserRequests({DateTime? startAfter, int? limit}) async {
    if (userRequestsIsFetching) return;
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    if (userRequestsHasNext && !userRequestsIsFetching) {
      if (mounted)
        setState(() {
          userRequestsIsFetching = true;
        });

      try {
        List<UserRequestModel> temp = await DatabaseRepository.instance
            .getAllUserRequests(
                limit: limit ?? AppConstants.nLimitUserRequests,
                startAfter: startAfter);
        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitUserRequests) ||
                temp.length == 0) userRequestsHasNext = false;
            userRequests.addAll(temp);
            userRequestsIsFetching = false;
            userRequestsFetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(
            message:
                'Error fetching user requests. PLease reload page and try again.');
        if (mounted)
          setState(() {
            userRequestsIsFetching = false;
          });
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      dateInput = TextEditingController();
      dateInput.text = '365';
      waitForValue<bool?>(
              () => AuthenticationRepository
                  .instance.currentUserModel.value?.isAdmin,
              timeout: Duration(seconds: 5))
          .then((val) {
        isAdmin = val ?? false;
        if (isAdmin) {
          if (_selectedIndex == 0) {
            getReports();
          } else if (_selectedIndex == 1) {
            getPosts();
          } else if (_selectedIndex == 2) {
            getBadges();
          } else if (_selectedIndex == 3) {
            getUserRequests();
          }
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: size.width < AppConstants.sidebarBreakpoint
          ? Container(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () {
                  AppPopups.openScrollablePopup(
                      maxWidth: 500,
                      body: actionsPanel(onClick: () {
                        AppPopups.closeDialog();
                      }),
                      footer: Container());
                },
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: AppStyles.pureWhite,
                ),
                extendedIconLabelSpacing: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
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
                    activeMenu: 4,
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
                    width:
                        (constraints.maxWidth >= AppConstants.navbarBreakpoint)
                            ? AppConstants.navbarWidth
                            : 100,
                    margin: EdgeInsets.only(right: 20),
                    padding:
                        (constraints.maxWidth >= AppConstants.navbarBreakpoint)
                            ? EdgeInsets.fromLTRB(60, 30, 0, 30)
                            : EdgeInsets.fromLTRB(40, 30, 0, 30),
                    child: SideBar(
                        constraints: constraints,
                        activeMenu: 4,
                        onPost: (post) {
                          Get.toNamed('/post/${post.postId}');
                        }),
                  ),
                Flexible(
                  child: Container(
                    constraints: (constraints.maxWidth >=
                            AppConstants.sidebarBreakpoint)
                        ? BoxConstraints(maxWidth: AppConstants.bodyMaxWidth)
                        : null,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height:
                              (constraints.maxWidth / constraints.maxHeight >
                                      0.8)
                                  ? 90
                                  : 70,
                          decoration: BoxDecoration(color: AppStyles.bgGrey),
                          alignment: Alignment.bottomCenter,
                          padding:
                              (constraints.maxWidth / constraints.maxHeight >
                                      0.8)
                                  ? EdgeInsets.only(left: 40, right: 40)
                                  : EdgeInsets.only(right: 20),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                                maxWidth: AppConstants.bodyWidth),
                            padding: EdgeInsets.only(bottom: 8, left: 16),
                            child: Row(
                              children: [
                                if (constraints.maxWidth /
                                        constraints.maxHeight <=
                                    0.8)
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
                                      'Admin Dashboard',
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
                            child: Container(
                              padding: (constraints.maxWidth /
                                          constraints.maxHeight >
                                      0.8)
                                  ? EdgeInsets.fromLTRB(40, 10, 40, 10)
                                  : EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: AppConstants.bodyWidth),
                                      margin: EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                            height: 45,
                                            constraints:
                                                BoxConstraints(maxWidth: 220),
                                            child: MaterialButtonIcon(
                                              onTap: () {
                                                if (mounted)
                                                  setState(() {
                                                    if (_selectedIndex != 0)
                                                      _selectedIndex = 0;
                                                    if (reports.length == 0)
                                                      getReports();
                                                  });
                                              },
                                              icon: Icons.report_outlined,
                                              iconPadding:
                                                  EdgeInsets.only(right: 8),
                                              text: 'Reports',
                                              withText:
                                                  constraints.maxWidth <= 800
                                                      ? false
                                                      : true,
                                              buttonColor: _selectedIndex == 0
                                                  ? AppStyles.primaryRed
                                                  : AppStyles.pureWhite,
                                              fontColor: _selectedIndex == 0
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                              iconColor: _selectedIndex == 0
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                            ),
                                          )),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Container(
                                            height: 45,
                                            constraints:
                                                BoxConstraints(maxWidth: 220),
                                            child: MaterialButtonIcon(
                                              onTap: () {
                                                if (mounted)
                                                  setState(() {
                                                    if (_selectedIndex != 1)
                                                      _selectedIndex = 1;
                                                  });
                                                if (posts.length == 0)
                                                  getPosts();
                                              },
                                              icon: Icons.alarm,
                                              iconPadding:
                                                  EdgeInsets.only(right: 8),
                                              text: 'Overdue',
                                              withText:
                                                  constraints.maxWidth <= 800
                                                      ? false
                                                      : true,
                                              buttonColor: _selectedIndex == 1
                                                  ? AppStyles.primaryYellow
                                                  : AppStyles.pureWhite,
                                              fontColor: _selectedIndex == 1
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                              iconColor: _selectedIndex == 1
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                            ),
                                          )),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Container(
                                            height: 45,
                                            constraints:
                                                BoxConstraints(maxWidth: 220),
                                            child: MaterialButtonIcon(
                                              onTap: () {
                                                if (mounted)
                                                  setState(() {
                                                    if (_selectedIndex != 2)
                                                      _selectedIndex = 2;
                                                    if (badges.length == 0)
                                                      getBadges();
                                                  });
                                              },
                                              icon: Icons.interests_outlined,
                                              iconPadding:
                                                  EdgeInsets.only(right: 8),
                                              text: 'Badges',
                                              withText:
                                                  constraints.maxWidth <= 800
                                                      ? false
                                                      : true,
                                              buttonColor: _selectedIndex == 2
                                                  ? AppStyles.primaryTeal
                                                  : AppStyles.pureWhite,
                                              fontColor: _selectedIndex == 2
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                              iconColor: _selectedIndex == 2
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                            ),
                                          )),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Container(
                                            height: 45,
                                            constraints:
                                                BoxConstraints(maxWidth: 220),
                                            child: MaterialButtonIcon(
                                              onTap: () {
                                                if (mounted)
                                                  setState(() {
                                                    if (_selectedIndex != 3)
                                                      _selectedIndex = 3;
                                                    if (userRequests.length ==
                                                        0) getUserRequests();
                                                  });
                                              },
                                              icon: Icons
                                                  .account_balance_outlined,
                                              iconPadding:
                                                  EdgeInsets.only(right: 8),
                                              text: 'Requests',
                                              withText:
                                                  constraints.maxWidth <= 800
                                                      ? false
                                                      : true,
                                              buttonColor: _selectedIndex == 3
                                                  ? AppStyles.primaryGreen
                                                  : AppStyles.pureWhite,
                                              fontColor: _selectedIndex == 3
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                              iconColor: _selectedIndex == 3
                                                  ? AppStyles.pureWhite
                                                  : AppStyles.mediumGray,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    if (_selectedIndex == 1)
                                      Container(
                                        height: 50,
                                        constraints: BoxConstraints(
                                            maxWidth: AppConstants.bodyWidth),
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Days ago: >',
                                                style: GoogleFonts.poppins(
                                                    color: AppStyles.mediumGray,
                                                    fontSize: 16,
                                                    height: 1)),
                                            SizedBox(width: 4),
                                            Container(
                                              width: 60,
                                              height: 36,
                                              child: TextFormField(
                                                controller: dateInput,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        AppStyles.primaryTeal,
                                                    fontSize: 16,
                                                    height: 1),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: AppStyles
                                                            .lightGrey),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: AppStyles
                                                            .primaryTeal),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            TextButton(
                                              onPressed: () {
                                                if (mounted)
                                                  setState(() {
                                                    if (dateInput
                                                        .text.isNotEmpty) {
                                                      dateFrom = DateTime.now()
                                                          .subtract(Duration(
                                                              days: int.parse(
                                                                  dateInput
                                                                      .text)));
                                                      posts = [];
                                                      postsHasNext = true;
                                                      postsFetchDone = false;
                                                      getPosts();
                                                    } else {
                                                      AppPopups.customToast(
                                                          message:
                                                              'Please enter how many days ago is the filter');
                                                    }
                                                  });
                                              },
                                              child: Text('Apply',
                                                  style: GoogleFonts.poppins(
                                                      color:
                                                          AppStyles.primaryTeal,
                                                      fontSize: 16,
                                                      height: 1)),
                                            )
                                          ],
                                        ),
                                      ),
                                    Expanded(
                                      child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        child: SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          child: Column(
                                            children: [
                                              if (_selectedIndex == 0)
                                                reportsFetchDone
                                                    ? Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth:
                                                                AppConstants
                                                                    .bodyWidth),
                                                        child: Column(
                                                          children: [
                                                            for (ReportModel report
                                                                in reports)
                                                              ReportProvider(
                                                                report: report,
                                                                onDelete:
                                                                    (reportId) {
                                                                  if (mounted)
                                                                    setState(
                                                                        () {
                                                                      reports.removeWhere((element) =>
                                                                          element
                                                                              .reportId ==
                                                                          reportId);
                                                                    });
                                                                },
                                                              ),
                                                            reportsHasNext
                                                                ? Container(
                                                                    width: double
                                                                        .infinity,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                20),
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          getReports(
                                                                              startAfter: reports.last.createdAt);
                                                                        },
                                                                        child: Text('Load more', style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1))))
                                                                : reports.length != 0
                                                                    ? EndOfResultContainer()
                                                                    : NoResultContainer(),
                                                          ],
                                                        ),
                                                      )
                                                    : ReportContainerShimmer(),
                                              if (_selectedIndex == 1)
                                                postsFetchDone
                                                    ? Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth:
                                                                AppConstants
                                                                    .bodyWidth),
                                                        child: Column(
                                                          children: [
                                                            for (PostModel post
                                                                in posts)
                                                              PostProvider(
                                                                key: ValueKey(post
                                                                        .postId +
                                                                    "Provider" +
                                                                    "AdminDashboardPosts"),
                                                                post: post,
                                                                onDelete:
                                                                    (postId) {
                                                                  if (mounted)
                                                                    setState(
                                                                        () {
                                                                      posts.removeWhere((element) =>
                                                                          element
                                                                              .postId ==
                                                                          postId);
                                                                    });
                                                                },
                                                              ),
                                                            postsHasNext
                                                                ? Container(
                                                                    width: double
                                                                        .infinity,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                20),
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          getPosts(
                                                                              startAfter: posts.last.createdAt);
                                                                        },
                                                                        child: Text('Load more', style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1))))
                                                                : posts.length != 0
                                                                    ? EndOfResultContainer()
                                                                    : NoResultContainer(),
                                                          ],
                                                        ),
                                                      )
                                                    : PostContainerShimmer(),
                                              if (_selectedIndex == 2)
                                                badgesFetchDone
                                                    ? Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth:
                                                                AppConstants
                                                                    .bodyWidth),
                                                        child: Column(
                                                          children: [
                                                            for (BadgeModel badge
                                                                in badges)
                                                              BadgeContainer(
                                                                badge: badge,
                                                                onTap: (bg) {
                                                                  AppPopups
                                                                      .openBadgeView(
                                                                          badge:
                                                                              badge,
                                                                          adminView:
                                                                              true,
                                                                          context:
                                                                              context,
                                                                          onEdit:
                                                                              (badgeNew) {
                                                                            if (mounted)
                                                                              setState(() {
                                                                                badges.removeWhere((element) => element.badgeId == badgeNew.badgeId);
                                                                                badges.insert(0, badgeNew);
                                                                              });
                                                                          },
                                                                          onDelete:
                                                                              (badgeDel) {
                                                                            if (mounted)
                                                                              setState(() {
                                                                                badges.removeWhere((element) => element.badgeId == badgeDel.badgeId);
                                                                              });
                                                                          });
                                                                },
                                                              ),
                                                            badgesHasNext
                                                                ? Container(
                                                                    width: double
                                                                        .infinity,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                20),
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          getBadges(
                                                                              startAfter: badges.last.createdAt);
                                                                        },
                                                                        child: Text('Load more', style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1))))
                                                                : badges.length != 0
                                                                    ? EndOfResultContainer()
                                                                    : NoResultContainer(),
                                                          ],
                                                        ),
                                                      )
                                                    : BadgeContainerShimmer(),
                                              if (_selectedIndex == 3)
                                                userRequestsFetchDone
                                                    ? Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth:
                                                                AppConstants
                                                                    .bodyWidth),
                                                        child: Column(
                                                          children: [
                                                            for (UserRequestModel userRequest
                                                                in userRequests)
                                                              UserRequestProvider(
                                                                userRequest:
                                                                    userRequest,
                                                                onApprove:
                                                                    () async {
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

                                                                  AppPopups.openLoadingDialog(
                                                                      'Approving user request...',
                                                                      AppConstants
                                                                          .aInFoundLoader);
                                                                  try {
                                                                    await DatabaseRepository
                                                                        .instance
                                                                        .approveUserRequest(
                                                                            request:
                                                                                userRequest);
                                                                    if (AuthenticationRepository
                                                                            .instance
                                                                            .currentUserModel
                                                                            .value!
                                                                            .uid ==
                                                                        userRequest
                                                                            .uid) {
                                                                      if (userRequest
                                                                              .type ==
                                                                          'ADMIN') {
                                                                        AuthenticationRepository.instance.currentUserModel.value = AuthenticationRepository
                                                                            .instance
                                                                            .currentUserModel
                                                                            .value!
                                                                            .copyWith(isAdmin: true);
                                                                      } else if (userRequest
                                                                              .type ==
                                                                          'VERIFIED') {
                                                                        AuthenticationRepository.instance.currentUserModel.value = AuthenticationRepository
                                                                            .instance
                                                                            .currentUserModel
                                                                            .value!
                                                                            .copyWith(isVerified: true);
                                                                      }
                                                                    }

                                                                    if (mounted)
                                                                      setState(
                                                                          () {
                                                                        userRequests.removeWhere((element) =>
                                                                            element.requestId ==
                                                                            userRequest.requestId);
                                                                      });
                                                                  } catch (e) {
                                                                    AppPopups
                                                                        .closeDialog();
                                                                    AppPopups.customToast(
                                                                        message:
                                                                            'Error approving user request. Please try again');
                                                                    return;
                                                                  }
                                                                },
                                                                onDecline:
                                                                    () async {
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

                                                                  AppPopups.openLoadingDialog(
                                                                      'Declining user request...',
                                                                      AppConstants
                                                                          .aInFoundLoader);

                                                                  try {
                                                                    await DatabaseRepository
                                                                        .instance
                                                                        .declineUserRequest(
                                                                            request:
                                                                                userRequest);
                                                                    if (mounted)
                                                                      setState(
                                                                          () {
                                                                        userRequests.removeWhere((element) =>
                                                                            element.requestId ==
                                                                            userRequest.requestId);
                                                                      });
                                                                  } catch (e) {
                                                                    AppPopups
                                                                        .closeDialog();
                                                                    AppPopups.customToast(
                                                                        message:
                                                                            'Error declining user request. Please try again');
                                                                    return;
                                                                  }
                                                                },
                                                              ),
                                                            userRequestsHasNext
                                                                ? Container(
                                                                    width: double
                                                                        .infinity,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                20),
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          getUserRequests(
                                                                              startAfter: userRequests.last.createdAt);
                                                                        },
                                                                        child: Text('Load more', style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1))))
                                                                : userRequests.length != 0
                                                                    ? EndOfResultContainer()
                                                                    : NoResultContainer(),
                                                          ],
                                                        ),
                                                      )
                                                    : UserRequestContainerShimmer(),
                                            ],
                                          ),
                                        ),
                                      ),
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
          child: actionsPanel(),
        ),
      ],
    );
  }

  Widget actionsPanel({VoidCallback? onClick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Actions',
            style: GoogleFonts.poppins(
                color: AppStyles.mediumGray,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1),
          ),
        ),
        if (_selectedIndex == 0)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                if (reports.length == 0) {
                  AppPopups.customToast(message: 'No reports to resolve');
                  return;
                }
                AppPopups.confirmDialog(
                    title: 'Resolve all reports',
                    content:
                        'Are you sure you want to mark all reports as resolved?',
                    confirmText: 'Resolve all',
                    accentColor: AppStyles.primaryTeal,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog(
                          'Marking reports as resolved...',
                          AppConstants.aInFoundLoader);
                      try {
                        for (ReportModel report in reports) {
                          await DatabaseRepository.instance
                              .markReportAsResolved(report: report);
                        }
                        if (mounted)
                          setState(() {
                            reports = [];
                            reportsHasNext = true;
                            reportsFetchDone = false;
                            getReports();
                          });

                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Successfully marked all reports as resolved.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Error resolving reports. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Mark all as resolved',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 0)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                if (reports.length == 0) {
                  AppPopups.customToast(message: 'No reports to ignore');
                  return;
                }

                AppPopups.confirmDialog(
                    title: 'Ignore all reports',
                    content:
                        'Are you sure you want to mark all reports as ignored?',
                    confirmText: 'Ignore all',
                    accentColor: AppStyles.mediumGray,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }
                      AppPopups.openLoadingDialog(
                          'Marking reports as ignored...',
                          AppConstants.aInFoundLoader);
                      try {
                        for (ReportModel report in reports) {
                          await DatabaseRepository.instance
                              .markReportAsIgnored(report: report);
                        }
                        if (mounted)
                          setState(() {
                            reports = [];
                            reportsHasNext = true;
                            reportsFetchDone = false;
                            getReports();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Successfully marked all reports as ignored.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Error ignoring reports. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Mark all as ignored',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 1)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                if (posts.length == 0) {
                  AppPopups.customToast(message: 'No posts to resolve');
                  return;
                }
                AppPopups.confirmDialog(
                    title: 'Resolve all posts',
                    content:
                        'Are you sure you want to mark all posts as resolved?',
                    confirmText: 'Resolve all',
                    accentColor: AppStyles.primaryTeal,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog(
                          'Marking posts as resolved...',
                          AppConstants.aInFoundLoader);

                      try {
                        for (PostModel post in posts) {
                          await DatabaseRepository.instance.updatePost(
                              post: post.copyWith(type: 'RESOLVED'));
                        }
                        if (mounted)
                          setState(() {
                            posts = [];
                            postsHasNext = true;
                            postsFetchDone = false;
                            getPosts();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Successfully marked all posts as resolved.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Error resolving posts. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Mark all as resolved',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 1)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                if (posts.length == 0) {
                  AppPopups.customToast(message: 'No posts to expire');
                  return;
                }
                AppPopups.confirmDialog(
                    title: 'Expire all posts',
                    content:
                        'Are you sure you want to mark all posts as expired?',
                    confirmText: 'Expire all',
                    accentColor: AppStyles.mediumGray,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog('Marking posts as expired...',
                          AppConstants.aInFoundLoader);
                      try {
                        for (PostModel post in posts) {
                          await DatabaseRepository.instance
                              .updatePost(post: post.copyWith(type: 'EXPIRED'));
                        }
                        if (mounted)
                          setState(() {
                            posts = [];
                            postsHasNext = true;
                            postsFetchDone = false;
                            getPosts();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Successfully marked all posts as expired.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Error expiring posts. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Mark all as expired',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 1)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                if (posts.length == 0) {
                  AppPopups.customToast(message: 'No posts to delete');
                  return;
                }
                AppPopups.confirmDialog(
                    title: 'Delete all posts',
                    content: 'Are you sure you want to delete all posts?',
                    confirmText: 'Delete all',
                    accentColor: AppStyles.primaryRed,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog(
                          'Deleting posts...', AppConstants.aInFoundLoader);
                      try {
                        for (PostModel post in posts) {
                          await DatabaseRepository.instance.deletePostById(
                              postId: post.postId, userId: post.userId);
                        }
                        if (mounted)
                          setState(() {
                            posts = [];
                            postsHasNext = true;
                            postsFetchDone = false;
                            getPosts();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Successfully deleted all posts.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Error deleting posts. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Delete all posts',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 2)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                AppPopups.openBadgeEditor(
                    isEditing: false,
                    onCreate: (badge) {
                      if (mounted)
                        setState(() {
                          badges.insert(0, badge);
                        });
                      if (onClick != null) onClick();
                    });
              },
              child: Text(
                'Create a new badge',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 3)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                AppPopups.confirmDialog(
                    title: 'Approve all requests',
                    content:
                        'Are you sure you want to approve all user requests?',
                    confirmText: 'Approve all',
                    accentColor: AppStyles.primaryTeal,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog('Approving user requests...',
                          AppConstants.aInFoundLoader);
                      try {
                        for (UserRequestModel userRequest in userRequests) {
                          await DatabaseRepository.instance
                              .approveUserRequest(request: userRequest);
                        }
                        if (mounted)
                          setState(() {
                            userRequests = [];
                            userRequestsHasNext = true;
                            userRequestsFetchDone = false;
                            getUserRequests();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Successfully approved all requests.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Error approving user requests. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Approve all requests',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
        if (_selectedIndex == 3)
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.only(left: 10),
            child: TextButton(
              onPressed: () async {
                AppPopups.confirmDialog(
                    title: 'Decline all requests',
                    content:
                        'Are you sure you want to decline all user requests?',
                    confirmText: 'Decline all',
                    accentColor: AppStyles.primaryRed,
                    onConfirm: () async {
                      final isConnected =
                          await NetworkManager.instance.isConnected();
                      if (!isConnected) {
                        AppPopups.customToast(
                            message: 'No Internet Connection');
                        return;
                      }

                      AppPopups.openLoadingDialog('Declining user requests...',
                          AppConstants.aInFoundLoader);
                      try {
                        for (UserRequestModel userRequest in userRequests) {
                          await DatabaseRepository.instance
                              .declineUserRequest(request: userRequest);
                        }
                        if (mounted)
                          setState(() {
                            userRequests = [];
                            userRequestsHasNext = true;
                            userRequestsFetchDone = false;
                            getUserRequests();
                          });
                        if (onClick != null) onClick();
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message: 'Successfully declined all requests.');
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'Error declining user requests. Please try again');
                        return;
                      }
                    });
              },
              child: Text(
                'Decline all requests',
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryTeal, fontSize: 16, height: 1),
              ),
            ),
          ),
      ],
    );
  }
}
