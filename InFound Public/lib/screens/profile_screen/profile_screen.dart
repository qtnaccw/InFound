import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool fromNavbar = Get.arguments != null ? Get.arguments['fromNavbar'] : false;
  final String username = Get.parameters['username'] ?? '';
  UserModel? user;
  int numPostsObs = 0;
  ScrollController _scrollController = ScrollController();

  List<PostModel> posts = <PostModel>[];
  List<BadgeModel> badges = <BadgeModel>[];
  bool hasNext = true;
  bool isFetching = false;
  bool userFetchDone = false;

  bool badgeFetchDone = false;

  Future getPosts({DateTime? startAfter, int? limit}) async {
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
        List<PostModel> temp = await DatabaseRepository.instance.getAllPostsByUser(
            userId: user!.uid, withComments: false, limit: limit ?? AppConstants.nLimitPosts, startAfter: startAfter);
        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitPosts) || temp.length == 0) hasNext = false;
            posts.addAll(temp);
            isFetching = false;
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

  Future getUser() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      UserModel? temp = await DatabaseRepository.instance.getUserInfo(byUsername: true, id: username);
      if (mounted)
        setState(() {
          user = temp;
          userFetchDone = true;
        });
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred. Please reload the page and try again.');
    }
  }

  Future getBadges() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      List<BadgeModel> temp = [];
      for (String badgeId in user!.badges) {
        BadgeModel? tempBadge = await DatabaseRepository.instance.getBadgeInfo(badgeId: badgeId);
        if (tempBadge != null) {
          temp.add(tempBadge);
        }
      }
      if (mounted)
        setState(() {
          badges = temp;
          badgeFetchDone = true;
        });
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred. Please reload the page and try again.');
    }
  }

  @override
  void initState() {
    if (mounted) {
      getUser().then((_) {
        if (user != null) {
          numPostsObs = user!.posts.length;
          getPosts();
          getBadges();
          _scrollController.addListener(() async {
            if (_scrollController.offset >= _scrollController.position.maxScrollExtent * 0.9 &&
                !_scrollController.position.outOfRange) {
              if (hasNext) {
                await getPosts(startAfter: posts.last.createdAt);
              }
            }
          });
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: size.width < AppConstants.sidebarBreakpoint && badgeFetchDone
          ? Container(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () {
                  AppPopups.openScrollablePopup(
                      title: 'Badges', maxWidth: 500, body: badgesPanel(context), footer: Container());
                },
                icon: Icon(
                  Icons.auto_awesome,
                  color: AppStyles.pureWhite,
                ),
                extendedIconLabelSpacing: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                label: Text(
                  'Badges',
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
                    activeMenu: 1,
                    onPost: (post) {
                      if (user == null || AuthenticationRepository.instance.currentUserModel.value == null) return;
                      if (user?.uid == AuthenticationRepository.instance.currentUserModel.value!.uid) {
                        if (mounted)
                          setState(() {
                            posts.insert(0, post);
                          });
                      }
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
                    width: (constraints.maxWidth >= AppConstants.navbarBreakpoint) ? AppConstants.navbarWidth : 100,
                    margin: EdgeInsets.only(right: 20),
                    padding: (constraints.maxWidth >= AppConstants.navbarBreakpoint)
                        ? EdgeInsets.fromLTRB(60, 30, 0, 30)
                        : EdgeInsets.fromLTRB(40, 30, 0, 30),
                    child: SideBar(
                        constraints: constraints,
                        activeMenu: 1,
                        onPost: (post) {
                          if (user == null || AuthenticationRepository.instance.currentUserModel.value == null) return;
                          if (user?.uid == AuthenticationRepository.instance.currentUserModel.value!.uid) {
                            if (mounted)
                              setState(() {
                                posts.insert(0, post);
                              });
                          }
                        }),
                  ),
                Flexible(
                    child: Container(
                  constraints: (constraints.maxWidth >= AppConstants.sidebarBreakpoint)
                      ? BoxConstraints(maxWidth: AppConstants.bodyMaxWidth)
                      : null,
                  height: constraints.maxHeight,
                  child: !userFetchDone
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryTeal),
                            ),
                          ),
                        )
                      : Column(
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
                                    if (constraints.maxWidth / constraints.maxHeight <= 0.8 && fromNavbar)
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
                                    if (!fromNavbar)
                                      Container(
                                          padding: EdgeInsets.only(right: 8),
                                          child: IconButton(
                                              onPressed: () {
                                                if (Navigator.canPop(context)) {
                                                  Get.back();
                                                } else {
                                                  Get.offNamed(AppRoutes.home);
                                                }
                                              },
                                              icon: Transform.translate(
                                                offset: Offset(-2, 0),
                                                child: Icon(
                                                  Icons.arrow_back_ios_new_outlined,
                                                  size: 30,
                                                  color: AppStyles.primaryTealLighter,
                                                ),
                                              ))),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        child: Text(
                                          (user != null) ? user!.userName : "Unknown",
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
                                  controller: _scrollController,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(bottom: 50),
                                  child: Container(
                                    padding: (constraints.maxWidth / constraints.maxHeight > 0.8)
                                        ? EdgeInsets.fromLTRB(40, 10, 40, 10)
                                        : EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Column(
                                      children: [
                                        user == null
                                            ? Container(
                                                height: 100,
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'User not found.',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                      color: AppStyles.lightGrey, fontSize: 14, height: 1),
                                                ),
                                              )
                                            : Container(),
                                        user != null
                                            ? UserProfileContainer(
                                                userModel: user!,
                                                uid: user!.uid,
                                                userProfileURL: user!.profileURL,
                                                username: user!.userName,
                                                bio: user!.bio,
                                                location: user!.location,
                                                fullName: user!.name,
                                                email: user!.email,
                                                phone: user!.phone,
                                                isEmailPublic: user!.isEmailPublic,
                                                isPhonePublic: user!.isPhonePublic,
                                                isLocationPublic: user!.isLocationPublic,
                                                isFullNamePublic: user!.isNamePublic,
                                                isVerified: user!.isVerified,
                                              )
                                            : Container(),
                                        user != null
                                            ? Container(
                                                constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                                width: double.infinity,
                                                margin: EdgeInsets.only(bottom: 16),
                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                child: DividerWIthText(
                                                  text: "Posts (${numPostsObs})",
                                                ),
                                              )
                                            : Container(),
                                        user != null
                                            ? Container(
                                                constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                                child: Column(
                                                  children: [
                                                    for (PostModel post in posts)
                                                      PostProvider(
                                                        key: ValueKey(post.postId + "Provider" + "Profile"),
                                                        post: post,
                                                        onDelete: (postId) {
                                                          if (mounted)
                                                            setState(() {
                                                              posts.removeWhere((element) => element.postId == postId);
                                                              numPostsObs--;
                                                            });
                                                        },
                                                      ),
                                                    hasNext
                                                        ? ReportContainerShimmer()
                                                        : posts.length != 0
                                                            ? EndOfResultContainer()
                                                            : NoResultContainer(),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                )),
                user != null
                    ? (constraints.maxWidth / constraints.maxHeight > 0.8)
                        ? (constraints.maxWidth >= AppConstants.sidebarBreakpoint)
                            ? Container(
                                width: AppConstants.sidebarWidth,
                                constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                                margin: EdgeInsets.only(left: 20),
                                padding: EdgeInsets.fromLTRB(0, 30, 60, 30),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    SearchBox(),
                                    if ((user ?? null) != null)
                                      Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(maxHeight: constraints.maxHeight - 136),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          color: AppStyles.pureWhite,
                                        ),
                                        padding: EdgeInsets.fromLTRB(8, 24, 8, 24),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              margin: EdgeInsets.only(bottom: 16),
                                              padding: EdgeInsets.only(left: 24, right: 16),
                                              child: Text(
                                                'Badges',
                                                style: GoogleFonts.poppins(
                                                    color: AppStyles.mediumGray,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: double.infinity,
                                                child: SingleChildScrollView(
                                                  physics: BouncingScrollPhysics(),
                                                  child: badgesPanel(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Container()
                        : Container()
                    : Container(
                        width: AppConstants.sidebarWidth,
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container badgesPanel(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: badgeFetchDone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badges.length == 0)
                    Container(
                      height: 100,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'No badges yet.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: AppStyles.lightGrey, fontSize: 14, height: 1),
                      ),
                    ),
                  if (badges.length > 0)
                    for (BadgeModel badge in badges)
                      BadgeContainer(
                        badge: badge,
                        onTap: (badgeN) {
                          if (user != null)
                            AppPopups.openBadgeView(
                                badge: badgeN,
                                userId: user!.uid,
                                context: context,
                                onRevoke: (revokedBadge) {
                                  if (mounted)
                                    setState(() {
                                      badges.removeWhere((element) => element.badgeId == revokedBadge.badgeId);
                                    });
                                });
                        },
                      ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (int i = 0; i < 5; i++) BadgeContainerShimmer()],
              ));
  }
}
