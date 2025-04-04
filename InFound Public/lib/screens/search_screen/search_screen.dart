import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/screens/home_screen/home_screen.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? query = Get.parameters['query'];
  List<String> qualifiedPosts = <String>[];
  GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  ScrollController _scrollController = ScrollController();

  List<PostModel> posts = <PostModel>[];
  bool hasNext = true;
  bool isFetching = false;

  List<String> postsWithinRadius = [];

  String location = "";
  bool enabledLost = true;
  bool enabledFound = true;
  bool enabledGeneral = true;
  bool enabledResolved = true;
  bool enabledExpired = true;
  bool enabledColor = false;
  bool enabledSize = false;
  bool enabledBrand = false;
  bool enabledAny = true;
  DateTime? startDate;
  DateTime? endDate;

  Future getQualifiedPosts() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }
    try {
      if (query == null) return;
      List<String> temp = await DatabaseRepository.instance.getPostsWithQuery(query: query!.toUpperCase());
      if (mounted)
        setState(() {
          qualifiedPosts = temp;
        });
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred. Please reload the page and try again.');
    }
  }

  Future getFilteredPosts({
    int limit = AppConstants.nLimitPosts,
    DateTime? startAfter,
  }) async {
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
          if (startAfter == null) posts.clear();
        });

      try {
        List<String> qual = [];

        if (location != '') {
          if (startAfter == null) {
            postsWithinRadius = await getPostsFilteredByLoc(location);
          }
          qual = getSimilarBetweenLists(postsWithinRadius, qualifiedPosts);
        } else {
          qual = qualifiedPosts;
        }

        List<PostModel> temp = [];

        // Split postsWithinRadius into chunks of 30
        List<List<String>> chunks = [];
        if (qual.isNotEmpty) {
          for (int i = 0; i < qual.length; i += 5) {
            chunks.add(qual.sublist(
              i,
              (i + 5 > qual.length) ? qual.length : i + 5,
            ));
          }
          // Iterate through each chunk and perform the query
          for (List<String> chunk in chunks) {
            printDebug(chunk.length);
            temp.addAll(await postQueryMain(startAfter, limit, chunk));
          }
        } else {
          temp.addAll(await postQueryMain(startAfter, limit, ["this"]));
        }
        if (mounted)
          setState(() {
            if (temp.length < limit || temp.isEmpty) hasNext = false;
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

  Future<List<PostModel>> postQueryMain(DateTime? startAfter, int limit, List<String>? chunk) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> query = firestore.collection('posts');

    if (enabledLost || enabledFound || enabledGeneral || enabledResolved || enabledExpired) {
      List<String> types = [];
      if (enabledLost) types.add('LOST');
      if (enabledFound) types.add('FOUND');
      if (enabledGeneral) types.add('GENERAL');
      if (enabledResolved) types.add('RESOLVED');
      if (enabledExpired) types.add('EXPIRED');
      query = query.where('type', whereIn: types);
    }

    if (chunk != null) {
      query = query.where('postId', whereIn: chunk);
    }

    if (enabledSize) {
      query = query.where('itemSize', isNotEqualTo: '');
    }

    if (enabledColor) {
      query = query.where('itemColor', isNotEqualTo: '');
    }

    if (enabledBrand) {
      query = query.where('itemBrand', isNotEqualTo: '');
    }

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    query = query.orderBy('createdAt', descending: true);

    if (startAfter != null) {
      query = query.startAfter([startAfter]);
    }

    query = query.limit(limit);

    var snapshot = await query.get();
    printDebug(snapshot.docs.length);
    return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc, [])).toList();
  }

  Future<List<String>> getPostsFilteredByLoc(String location) async {
    List<String> postIds = [];
    List<double> coords = AppFormatter.parseLocation(location);
    double lat = coords[0];
    double long = coords[1];
    double radius = coords[2];

    Map<dynamic, dynamic>? temp = await DatabaseRepository.instance.getPostsRD();
    if (temp != null) {
      temp.forEach((key, value) {
        if (value['latitude'] == null || value['longitude'] == null || value['radius'] == null) {
          return;
        }
        double postLat = value['latitude'] as double;
        double postLong = value['longitude'] as double;
        double postRadius = value['radius'] as double;
        if (isPostVisible(
            userLat: lat,
            userLon: long,
            userRadius: radius,
            postLat: postLat,
            postLon: postLong,
            postRadius: postRadius)) {
          postIds.add(key);
        }
      });
    }
    return postIds;
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      waitForValue<String>(() => query, timeout: Duration(seconds: 5)).then((val) {
        if (val != null) {
          getQualifiedPosts().then((_) async {
            await getFilteredPosts();
          });
        } else {
          hasNext = false;
          isFetching = false;
        }
      });
      _scrollController.addListener(() async {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent * 0.9 &&
            !_scrollController.position.outOfRange) {
          if (hasNext) {
            await getFilteredPosts(startAfter: posts.last.createdAt);
          }
        }
      });
    }
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
      floatingActionButton: size.width < AppConstants.sidebarBreakpoint
          ? Container(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () {
                  AppPopups.openScrollablePopup(
                      body: FilterPanel(
                          initlocation: location,
                          initenabledLost: enabledLost,
                          initenabledFound: enabledFound,
                          initenabledGeneral: enabledGeneral,
                          initenabledResolved: enabledResolved,
                          initenabledExpired: enabledExpired,
                          initenabledColor: enabledColor,
                          initenabledSize: enabledSize,
                          initenabledBrand: enabledBrand,
                          initenabledAny: enabledAny,
                          initstartDate: startDate,
                          initendDate: endDate,
                          onFilter: (enabledLostNew,
                              enabledFoundNew,
                              enabledGeneralNew,
                              enabledResolvedNew,
                              enabledExpiredNew,
                              locationNew,
                              enabledAnyNew,
                              enabledColorNew,
                              enabledSizeNew,
                              enabledBrandNew,
                              startDateNew,
                              endDateNew) async {
                            await onFilterFunction(
                                enabledLostNew,
                                enabledFoundNew,
                                enabledGeneralNew,
                                enabledResolvedNew,
                                enabledExpiredNew,
                                locationNew,
                                enabledAnyNew,
                                enabledColorNew,
                                enabledSizeNew,
                                enabledBrandNew,
                                startDateNew,
                                endDateNew);
                            AppPopups.closeDialog();
                          }),
                      footer: Container());
                },
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: AppStyles.pureWhite,
                ),
                extendedIconLabelSpacing: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                label: Text(
                  'Filter',
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
                    activeMenu: constraints.maxWidth < AppConstants.sidebarBreakpoint ? 6 : 0,
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
                        activeMenu: constraints.maxWidth < AppConstants.sidebarBreakpoint ? 6 : 0,
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
                                      query == null ? 'Search' : 'Search Results for: $query',
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

                                // Refresh Button
                                if (query != null)
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: IconButton(
                                      icon: Icon(Icons.refresh_rounded),
                                      iconSize: 30,
                                      color: AppStyles.primaryTeal,
                                      onPressed: () async {
                                        if (mounted)
                                          setState(() {
                                            _refreshKey.currentState?.show();
                                            qualifiedPosts.clear();
                                            posts.clear();
                                            hasNext = true;
                                            _scrollController.animateTo(
                                              0,
                                              duration: Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          });
                                        await getQualifiedPosts().then((_) async {
                                          await getFilteredPosts();
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (constraints.maxWidth < AppConstants.sidebarBreakpoint)
                          Container(
                            padding: (constraints.maxWidth / constraints.maxHeight > 0.8)
                                ? EdgeInsets.only(left: 40, right: 40)
                                : EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                                constraints: BoxConstraints(maxWidth: AppConstants.bodyWidth),
                                margin: EdgeInsets.only(top: 10),
                                child: SearchBox(
                                  initialValue: query,
                                )),
                          ),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: RefreshIndicator(
                              key: _refreshKey,
                              onRefresh: () async {
                                if (mounted)
                                  setState(() {
                                    posts.clear();
                                    hasNext = true;
                                    _scrollController.jumpTo(0);
                                  });

                                await getFilteredPosts();
                                return Future.value(true);
                              },
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
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            for (PostModel post in posts)
                                              PostProvider(
                                                key: ValueKey(post.postId + "Provider" + "Search"),
                                                post: post,
                                                onDelete: (postId) {
                                                  if (mounted)
                                                    setState(() {
                                                      posts.removeWhere((element) => element.postId == postId);
                                                      postsWithinRadius.removeWhere((element) => element == postId);
                                                      qualifiedPosts.removeWhere((element) => element == postId);
                                                    });
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      query == null
                                          ? Container(
                                              width: double.infinity,
                                              height: 100,
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              alignment: Alignment.center,
                                              child: Text('Start your search by entering a query in the search bar.',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppStyles.mediumGray)),
                                            )
                                          : hasNext
                                              ? PostContainerShimmer()
                                              : posts.length != 0
                                                  ? EndOfResultContainer()
                                                  : NoResultContainer(),
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
                                SearchBox(
                                  initialValue: query,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppStyles.pureWhite,
                                  ),
                                  padding: EdgeInsets.fromLTRB(18, 24, 18, 24),
                                  child: FilterPanel(
                                      initlocation: location,
                                      initenabledLost: enabledLost,
                                      initenabledFound: enabledFound,
                                      initenabledGeneral: enabledGeneral,
                                      initenabledResolved: enabledResolved,
                                      initenabledExpired: enabledExpired,
                                      initenabledColor: enabledColor,
                                      initenabledSize: enabledSize,
                                      initenabledBrand: enabledBrand,
                                      initenabledAny: enabledAny,
                                      initstartDate: startDate,
                                      initendDate: endDate,
                                      onFilter: (enabledLostNew,
                                          enabledFoundNew,
                                          enabledGeneralNew,
                                          enabledResolvedNew,
                                          enabledExpiredNew,
                                          locationNew,
                                          enabledAnyNew,
                                          enabledColorNew,
                                          enabledSizeNew,
                                          enabledBrandNew,
                                          startDateNew,
                                          endDateNew) async {
                                        await onFilterFunction(
                                            enabledLostNew,
                                            enabledFoundNew,
                                            enabledGeneralNew,
                                            enabledResolvedNew,
                                            enabledExpiredNew,
                                            locationNew,
                                            enabledAnyNew,
                                            enabledColorNew,
                                            enabledSizeNew,
                                            enabledBrandNew,
                                            startDateNew,
                                            endDateNew);
                                      }),
                                ),
                              ],
                            ))
                        : Container()
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> onFilterFunction(
      bool enabledLostNew,
      bool enabledFoundNew,
      bool enabledGeneralNew,
      bool enabledResolvedNew,
      bool enabledExpiredNew,
      String locationNew,
      bool enabledAnyNew,
      bool enabledColorNew,
      bool enabledSizeNew,
      bool enabledBrandNew,
      DateTime? startDateNew,
      DateTime? endDateNew) async {
    if (!isFetching) {
      if (mounted)
        setState(() {
          isFetching = true;
          enabledLost = enabledLostNew;
          enabledFound = enabledFoundNew;
          enabledGeneral = enabledGeneralNew;
          enabledResolved = enabledResolvedNew;
          enabledExpired = enabledExpiredNew;
          location = locationNew;

          if (locationNew == '') {
            postsWithinRadius.clear();
          }
          enabledAny = enabledAnyNew;
          enabledColor = enabledColorNew;
          enabledSize = enabledSizeNew;
          enabledBrand = enabledBrandNew;
          startDate = startDateNew;
          endDate = endDateNew;
          _refreshKey.currentState?.show();
          posts.clear();
          hasNext = true;
          _scrollController.jumpTo(0);
        });
      await getFilteredPosts();
      if (mounted)
        setState(() {
          isFetching = false;
        });
    }
  }
}
