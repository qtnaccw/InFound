import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class BookmarksScreen extends StatefulWidget {
  BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  ScrollController _scrollController = ScrollController();

  List<PostModel> posts = [];
  bool hasNext = true;
  bool isFetching = false;
  bool fetchDone = false;
  RxInt numberBookmarks = 0.obs;

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
        List<PostModel> temp = await DatabaseRepository.instance.getAllPostsInList(
            postIds: (AuthenticationRepository.instance.currentUserModel.value != null &&
                    AuthenticationRepository.instance.currentUserModel.value!.bookmarks.isNotEmpty)
                ? AuthenticationRepository.instance.currentUserModel.value!.bookmarks
                : ["THIS"],
            limit: limit ?? AppConstants.nLimitPosts,
            startAfter: startAfter);
        if (mounted)
          setState(() {
            if (temp.length < (limit ?? AppConstants.nLimitPosts) || temp.length == 0) hasNext = false;
            posts.addAll(temp);
            numberBookmarks.value = posts.length;
            isFetching = false;
            fetchDone = true;
          });
      } catch (e) {
        AppPopups.customToast(message: 'An error occurred fetchin posts. Please Reload the page and try again');
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
          .then((val) {
        if (val != null) {
          getPosts();
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });

      _scrollController.addListener(() async {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent * 0.9 &&
            !_scrollController.position.outOfRange) {
          if (hasNext) {
            await getPosts(startAfter: posts.last.createdAt);
          }
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
                    activeMenu: 3,
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
                    width: (constraints.maxWidth >= AppConstants.navbarBreakpoint) ? AppConstants.navbarWidth : 100,
                    margin: EdgeInsets.only(right: 20),
                    padding: (constraints.maxWidth >= AppConstants.navbarBreakpoint)
                        ? EdgeInsets.fromLTRB(60, 30, 0, 30)
                        : EdgeInsets.fromLTRB(40, 30, 0, 30),
                    child: SideBar(
                        constraints: constraints,
                        activeMenu: 3,
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
                                    child: Obx(
                                      () => Text(
                                        'Bookmarks ${numberBookmarks.value == 0 ? "" : "(${numberBookmarks.value})"}',
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
                                child: Container(
                                  child: Column(
                                    children: [
                                      fetchDone
                                          ? Container(
                                              constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                              child: Column(
                                                children: [
                                                  for (PostModel post in posts)
                                                    PostProvider(
                                                      key: ValueKey(post.postId + "Provider" + "Bookmarks"),
                                                      post: post,
                                                      onDelete: (postId) {
                                                        if (mounted)
                                                          setState(() {
                                                            posts.removeWhere((element) => element.postId == postId);
                                                          });
                                                      },
                                                      onBookmarkCallback: (marked, postId) {
                                                        if (mounted)
                                                          setState(() {
                                                            if (!marked) {
                                                              posts.removeWhere((element) => element.postId == postId);
                                                            }
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
                                          : ReportContainerShimmer(),
                                    ],
                                  ),
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
                                  child: actionsPanel(),
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

  Column actionsPanel({VoidCallback? onClick}) {
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
          margin: EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () async {
              if (posts.length > 0) {
                final isConnected = await NetworkManager.instance.isConnected();
                if (!isConnected) {
                  AppPopups.customToast(message: 'No Internet Connection');
                  return;
                }
                try {
                  await DatabaseRepository.instance
                      .clearBookmarks(userId: AuthenticationRepository.instance.currentUserModel.value!.uid);
                  if (mounted)
                    setState(() {
                      posts = [];
                      hasNext = false;
                    });
                  if (onClick != null) onClick();
                } catch (e) {
                  AppPopups.customToast(message: 'An error occurred clearing bookmarks. Please try again');
                }
              } else {
                AppPopups.customToast(message: 'Bookmarks is already empty');
              }
            },
            child: Text(
              'Clear bookmarks',
              style: GoogleFonts.poppins(color: AppStyles.primaryTeal, fontSize: 16, height: 1),
            ),
          ),
        ),
      ],
    );
  }
}
