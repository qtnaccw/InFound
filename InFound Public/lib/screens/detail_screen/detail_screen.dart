import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class DetailScreen extends StatefulWidget {
  DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  PostModel? post;
  bool postLoading = true;
  Future getPost() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      PostModel? temp = await DatabaseRepository.instance.getSpecificPost(
        postId: Get.parameters['postID'] ?? '',
        withComments: false,
      );
      if (mounted) {
        setState(() {
          post = temp;
          postLoading = false;
        });
      }
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred. Please reload the page and try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getPost();
    }
  }

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
                    activeMenu: 0,
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
                        activeMenu: 0,
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
                                Padding(
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
                                      'Post',
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
                                    Container(
                                      constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                      child: postLoading
                                          ? ReportContainerShimmer()
                                          : post != null
                                              ? PostProvider(
                                                  key: ValueKey(post!.postId + "Provider" + "Detail"),
                                                  post: post!,
                                                  withComments: true,
                                                  expanded: true,
                                                  onDelete: (postId) {
                                                    Get.offNamed(AppRoutes.home);
                                                  },
                                                )
                                              : Container(
                                                  height: 200,
                                                  child: Center(
                                                    child: Text(
                                                      "Post not found.",
                                                      style: GoogleFonts.poppins(
                                                        color: AppStyles.mediumGray,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500,
                                                      ),
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
                            alignment: Alignment.topCenter)
                        : Container()
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }
}
