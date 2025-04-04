import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/containers/shimmer_containers.dart';
import 'package:infound/components/navbar.dart';
import 'package:infound/main.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/styles.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
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
        if (location != '' && startAfter == null) {
          postsWithinRadius = await getPostsFilteredByLoc(location);
        }

        List<PostModel> temp = [];

        // Split postsWithinRadius into chunks of 30
        List<List<String>> chunks = [];
        if (location != '' && postsWithinRadius.isNotEmpty) {
          for (int i = 0; i < postsWithinRadius.length; i += 5) {
            chunks.add(postsWithinRadius.sublist(
              i,
              (i + 5 > postsWithinRadius.length)
                  ? postsWithinRadius.length
                  : i + 5,
            ));
          }
          // Iterate through each chunk and perform the query
          for (List<String> chunk in chunks) {
            temp.addAll(await postQueryMain(startAfter, limit, chunk));
          }
        } else if (location != '' && postsWithinRadius.isEmpty) {
          temp.addAll(await postQueryMain(startAfter, limit, ["this"]));
        } else {
          temp.addAll(await postQueryMain(startAfter, limit, null));
        }
        if (mounted)
          setState(() {
            if (temp.length < limit || temp.isEmpty) hasNext = false;
            posts.addAll(temp);
            isFetching = false;
          });
      } catch (e) {
        AppPopups.customToast(message: 'An error occurred. Please try again.');
        if (mounted)
          setState(() {
            isFetching = false;
          });
      }
    }
  }

  Future<List<PostModel>> postQueryMain(
      DateTime? startAfter, int limit, List<String>? chunk) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> query = firestore.collection('posts');

    if (enabledLost ||
        enabledFound ||
        enabledGeneral ||
        enabledResolved ||
        enabledExpired) {
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
    return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc, [])).toList();
  }

  Future<List<String>> getPostsFilteredByLoc(String location) async {
    List<String> postIds = [];
    List<double> coords = AppFormatter.parseLocation(location);
    double lat = coords[0];
    double long = coords[1];
    double radius = coords[2];

    Map<dynamic, dynamic>? temp =
        await DatabaseRepository.instance.getPostsRD();
    if (temp != null) {
      temp.forEach((key, value) {
        if (value['latitude'] == null ||
            value['longitude'] == null ||
            value['radius'] == null) {
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
      getFilteredPosts();
      _scrollController.addListener(() async {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent * 0.9 &&
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
                      maxWidth: 500,
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
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
                    activeMenu: 0,
                    onPost: (post) {
                      if (mounted)
                        setState(() {
                          posts.insert(0, post);
                        });
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
                        activeMenu: 0,
                        onPost: (post) {
                          if (mounted)
                            setState(() {
                              posts.insert(0, post);
                            });
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
                                      'Home',
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
                                          posts.clear();
                                          hasNext = true;
                                          _scrollController.jumpTo(
                                            0,
                                          );
                                        });
                                      await getFilteredPosts();
                                    },
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
                                  padding: (constraints.maxWidth /
                                              constraints.maxHeight >
                                          0.8)
                                      ? EdgeInsets.fromLTRB(40, 10, 40, 10)
                                      : EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Column(
                                    children: [
                                      Obx(
                                        () => AuthenticationRepository.instance
                                                    .currentUserModel.value !=
                                                null
                                            ? ComposeWidget(
                                                profileURL:
                                                    AuthenticationRepository
                                                        .instance
                                                        .currentUserModel
                                                        .value!
                                                        .profileURL,
                                                onPost: (post) {
                                                  if (mounted)
                                                    setState(() {
                                                      posts.insert(0, post);
                                                    });
                                                })
                                            : Container(),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            for (PostModel post in posts)
                                              PostProvider(
                                                key: ValueKey(post.postId +
                                                    "Provider" +
                                                    "Home"),
                                                post: post,
                                                onDelete: (postId) {
                                                  if (mounted)
                                                    setState(() {
                                                      posts.removeWhere(
                                                          (element) =>
                                                              element.postId ==
                                                              postId);
                                                    });
                                                },
                                              )
                                          ],
                                        ),
                                      ),
                                      hasNext
                                          ? ReportContainerShimmer()
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
                                SearchBox(),
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
                                    },
                                  ),
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

class FilterPanel extends StatefulWidget {
  const FilterPanel({
    super.key,
    required this.onFilter,
    this.initlocation = "",
    this.initenabledLost = true,
    this.initenabledFound = true,
    this.initenabledGeneral = true,
    this.initenabledResolved = true,
    this.initenabledExpired = true,
    this.initenabledColor = false,
    this.initenabledSize = false,
    this.initenabledBrand = false,
    this.initenabledAny = true,
    this.initstartDate,
    this.initendDate,
  });

  final Function(bool, bool, bool, bool, bool, String, bool, bool, bool, bool,
      DateTime?, DateTime?) onFilter;
  final String initlocation;
  final bool initenabledLost;
  final bool initenabledFound;
  final bool initenabledGeneral;
  final bool initenabledResolved;
  final bool initenabledExpired;
  final bool initenabledColor;
  final bool initenabledSize;
  final bool initenabledBrand;
  final bool initenabledAny;
  final DateTime? initstartDate;
  final DateTime? initendDate;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  String location = "";
  String currentWithField = "Any/None";
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

  @override
  void initState() {
    super.initState();
    setState(() {
      location = widget.initlocation;
      enabledLost = widget.initenabledLost;
      enabledFound = widget.initenabledFound;
      enabledGeneral = widget.initenabledGeneral;
      enabledResolved = widget.initenabledResolved;
      enabledExpired = widget.initenabledExpired;
      enabledColor = widget.initenabledColor;
      enabledSize = widget.initenabledSize;
      enabledBrand = widget.initenabledBrand;
      enabledAny = widget.initenabledAny;
      startDate = widget.initstartDate;
      endDate = widget.initendDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      'Filters',
                      style: GoogleFonts.poppins(
                          color: AppStyles.mediumGray,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1),
                    ),
                  ),
                ),
                if (size.width < AppConstants.sidebarBreakpoint)
                  MaterialButtonIcon(
                    onTap: () {
                      widget.onFilter(
                          enabledLost,
                          enabledFound,
                          enabledGeneral,
                          enabledResolved,
                          enabledExpired,
                          location,
                          enabledAny,
                          enabledColor,
                          enabledSize,
                          enabledBrand,
                          startDate,
                          endDate);
                    },
                    icon: Icons.filter_alt_outlined,
                    text: "Filter",
                    width: 80,
                    height: 36,
                    iconSize: 20,
                    fontSize: 14,
                    withIcon: true,
                    withText: true,
                  ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppStyles.pureWhite,
                boxShadow: [
                  AppStyles()
                      .lightBoxShadow(AppStyles.primaryTeal.withAlpha(100))
                ]),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                childrenPadding: EdgeInsets.all(8),
                title: Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                      color: AppStyles.mediumGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1),
                ),
                children: [
                  TypeSelectionOption(
                    type: "LOST",
                    color: AppStyles.primaryRed,
                    initialValue: enabledLost,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledLost = value ?? false;
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  TypeSelectionOption(
                    type: "FOUND",
                    color: AppStyles.primaryYellow,
                    initialValue: enabledFound,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledFound = value ?? false;
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  TypeSelectionOption(
                    type: "GENERAL",
                    color: AppStyles.primaryTeal,
                    initialValue: enabledGeneral,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledGeneral = value ?? false;
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  TypeSelectionOption(
                    type: "RESOLVED",
                    color: AppStyles.primaryGreen,
                    initialValue: enabledResolved,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledResolved = value ?? false;
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  TypeSelectionOption(
                    type: "EXPIRED",
                    color: AppStyles.mediumGray,
                    initialValue: enabledExpired,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledExpired = value ?? false;
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppStyles.pureWhite,
                boxShadow: [
                  AppStyles()
                      .lightBoxShadow(AppStyles.primaryTeal.withAlpha(100))
                ]),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                childrenPadding: EdgeInsets.all(8),
                title: Text(
                  'Location',
                  style: GoogleFonts.poppins(
                      color: AppStyles.mediumGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1),
                ),
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 25,
                                      color: AppStyles.mediumGray,
                                    )),
                                Expanded(
                                  child: Text(
                                    location == ""
                                        ? "No location selected"
                                        : location,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppStyles.mediumGray),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: TextButton(
                                    onPressed: () {
                                      AppPopups.openMapPicker(
                                          onSubmit: (address, coord) {
                                        if (mounted)
                                          setState(() {
                                            location = address;
                                          });
                                        if (size.width <
                                            AppConstants.sidebarBreakpoint)
                                          widget.onFilter(
                                              enabledLost,
                                              enabledFound,
                                              enabledGeneral,
                                              enabledResolved,
                                              enabledExpired,
                                              location,
                                              enabledAny,
                                              enabledColor,
                                              enabledSize,
                                              enabledBrand,
                                              startDate,
                                              endDate);
                                      });
                                    },
                                    child: Text(
                                      'CHANGE',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppStyles.primaryTeal),
                                    ),
                                  ),
                                ),
                                if (location != '')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: TextButton(
                                      onPressed: () {
                                        if (mounted)
                                          setState(() {
                                            location = "";
                                          });
                                        if (size.width <
                                            AppConstants.sidebarBreakpoint)
                                          widget.onFilter(
                                              enabledLost,
                                              enabledFound,
                                              enabledGeneral,
                                              enabledResolved,
                                              enabledExpired,
                                              location,
                                              enabledAny,
                                              enabledColor,
                                              enabledSize,
                                              enabledBrand,
                                              startDate,
                                              endDate);
                                      },
                                      child: Text(
                                        'REMOVE',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppStyles.primaryRed),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppStyles.pureWhite,
                boxShadow: [
                  AppStyles()
                      .lightBoxShadow(AppStyles.primaryTeal.withAlpha(100))
                ]),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                childrenPadding: EdgeInsets.all(8),
                title: Text(
                  'With fields',
                  style: GoogleFonts.poppins(
                      color: AppStyles.mediumGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1),
                ),
                children: [
                  FieldSelectionOption(
                    field: "Any/None",
                    icon: Icons.all_inclusive_rounded,
                    color: AppStyles.primaryTeal,
                    groupValue: currentWithField,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledAny = value == "Any/None";
                          if (enabledAny) {
                            currentWithField = "Any/None";
                            enabledColor = false;
                            enabledSize = false;
                            enabledBrand = false;
                          }
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  FieldSelectionOption(
                    field: "Color",
                    icon: Icons.color_lens_outlined,
                    color: AppStyles.primaryTeal,
                    groupValue: currentWithField,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledColor = value == "Color";
                          if (enabledColor) {
                            currentWithField = "Color";
                            enabledAny = false;
                            enabledSize = false;
                            enabledBrand = false;
                          }
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  FieldSelectionOption(
                    field: "Size",
                    icon: Icons.format_line_spacing_outlined,
                    color: AppStyles.primaryTeal,
                    groupValue: currentWithField,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledSize = value == "Size";
                          if (enabledSize) {
                            currentWithField = "Size";
                            enabledAny = false;
                            enabledColor = false;
                            enabledBrand = false;
                          }
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                  FieldSelectionOption(
                    field: "Brand",
                    icon: Icons.loyalty_outlined,
                    color: AppStyles.primaryTeal,
                    groupValue: currentWithField,
                    onChanged: (value) {
                      if (mounted)
                        setState(() {
                          enabledBrand = value == "Brand";
                          if (enabledBrand) {
                            currentWithField = "Brand";
                            enabledAny = false;
                            enabledSize = false;
                            enabledColor = false;
                          }
                        });
                      if (!(size.width < AppConstants.sidebarBreakpoint))
                        widget.onFilter(
                            enabledLost,
                            enabledFound,
                            enabledGeneral,
                            enabledResolved,
                            enabledExpired,
                            location,
                            enabledAny,
                            enabledColor,
                            enabledSize,
                            enabledBrand,
                            startDate,
                            endDate);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppStyles.pureWhite,
                boxShadow: [
                  AppStyles()
                      .lightBoxShadow(AppStyles.primaryTeal.withAlpha(100))
                ]),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                childrenPadding: EdgeInsets.all(8),
                title: Text(
                  'Date',
                  style: GoogleFonts.poppins(
                      color: AppStyles.mediumGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1),
                ),
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.date_range_rounded,
                                      size: 25,
                                      color: AppStyles.mediumGray,
                                    )),
                                Expanded(
                                  child: Text(
                                    startDate == null
                                        ? 'NONE'
                                        : DateFormat('MM/dd/yyyy\nHH:mm:ss')
                                            .format(startDate!),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppStyles.mediumGray),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: TextButton(
                              onPressed: () async {
                                if (startDate != null) {
                                  if (mounted)
                                    setState(() {
                                      startDate = null;
                                    });
                                  if (size.width <
                                      AppConstants.sidebarBreakpoint)
                                    widget.onFilter(
                                        enabledLost,
                                        enabledFound,
                                        enabledGeneral,
                                        enabledResolved,
                                        enabledExpired,
                                        location,
                                        enabledAny,
                                        enabledColor,
                                        enabledSize,
                                        enabledBrand,
                                        startDate,
                                        endDate);
                                } else {
                                  DateTime? newDate = await selectDateTime(
                                      context: context,
                                      firstDate: DateTime(2025, 1, 1, 0, 0, 0),
                                      initialDate: startDate,
                                      lastDate: endDate,
                                      confirmText: "SET START");
                                  if (newDate != null) {
                                    if (endDate != null &&
                                        (newDate.isAfter(endDate!) ||
                                            newDate
                                                .isAtSameMomentAs(endDate!))) {
                                      AppPopups.errorSnackBar(
                                          title: "Invalid start date",
                                          message:
                                              "Start date cannot be after end date");
                                    } else {
                                      if (mounted)
                                        setState(() {
                                          startDate = newDate;
                                        });
                                      if (size.width <
                                          AppConstants.sidebarBreakpoint)
                                        widget.onFilter(
                                            enabledLost,
                                            enabledFound,
                                            enabledGeneral,
                                            enabledResolved,
                                            enabledExpired,
                                            location,
                                            enabledAny,
                                            enabledColor,
                                            enabledSize,
                                            enabledBrand,
                                            startDate,
                                            endDate);
                                    }
                                  }
                                }
                              },
                              child: Text(
                                startDate == null ? 'SET START' : "REMOVE",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: endDate == null
                                        ? AppStyles.primaryTeal
                                        : AppStyles.primaryRed),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.date_range_outlined,
                                      size: 25,
                                      color: AppStyles.mediumGray,
                                    )),
                                Expanded(
                                  child: Text(
                                    endDate == null
                                        ? 'NONE'
                                        : DateFormat('MM/dd/yyyy\nHH:mm:ss')
                                            .format(endDate!),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppStyles.mediumGray),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: TextButton(
                              onPressed: () async {
                                if (endDate != null) {
                                  if (mounted)
                                    setState(() {
                                      endDate = null;
                                    });
                                  if (size.width <
                                      AppConstants.sidebarBreakpoint)
                                    widget.onFilter(
                                        enabledLost,
                                        enabledFound,
                                        enabledGeneral,
                                        enabledResolved,
                                        enabledExpired,
                                        location,
                                        enabledAny,
                                        enabledColor,
                                        enabledSize,
                                        enabledBrand,
                                        startDate,
                                        endDate);
                                } else {
                                  DateTime? newDate = await selectDateTime(
                                      context: context,
                                      firstDate: startDate,
                                      initialDate: startDate,
                                      lastDate: DateTime.now(),
                                      confirmText: "SET END");

                                  if (newDate != null) {
                                    if (startDate != null &&
                                        (newDate.isBefore(startDate!) ||
                                            newDate.isAtSameMomentAs(
                                                startDate!))) {
                                      AppPopups.errorSnackBar(
                                          title: "Invalid end date",
                                          message:
                                              "End date cannot be before start date");
                                    } else {
                                      if (mounted)
                                        setState(() {
                                          endDate = newDate;
                                        });
                                      if (size.width <
                                          AppConstants.sidebarBreakpoint)
                                        widget.onFilter(
                                            enabledLost,
                                            enabledFound,
                                            enabledGeneral,
                                            enabledResolved,
                                            enabledExpired,
                                            location,
                                            enabledAny,
                                            enabledColor,
                                            enabledSize,
                                            enabledBrand,
                                            startDate,
                                            endDate);
                                    }
                                  }
                                }
                              },
                              child: Text(
                                endDate == null ? 'SET END' : "REMOVE",
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: endDate == null
                                        ? AppStyles.primaryTeal
                                        : AppStyles.primaryRed),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypeSelectionOption extends StatefulWidget {
  TypeSelectionOption({
    super.key,
    required this.type,
    required this.color,
    required this.onChanged,
    this.initialValue = true,
  });

  final String type;
  final Color color;
  final Function(bool?) onChanged;
  final bool initialValue;

  @override
  State<TypeSelectionOption> createState() => _TypeSelectionOptionState();
}

class _TypeSelectionOptionState extends State<TypeSelectionOption> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Row(
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: AppStyles.lightGrey,
              ),
              child: Checkbox(
                  value: widget.initialValue,
                  onChanged: (value) {
                    widget.onChanged(value);
                  },
                  activeColor: AppStyles.primaryTeal,
                  checkColor: AppStyles.pureWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
            ),
            Container(
              decoration: BoxDecoration(
                  color: widget.color, borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                widget.type,
                style: GoogleFonts.poppins(
                    color: AppStyles.pureWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1),
              ),
            ),
          ],
        ));
  }
}

class FieldSelectionOption extends StatefulWidget {
  FieldSelectionOption(
      {super.key,
      required this.field,
      required this.color,
      required this.onChanged,
      required this.icon,
      required this.groupValue});

  final String field;
  final IconData icon;
  final Color color;
  final Function(String?) onChanged;
  final String groupValue;

  @override
  State<FieldSelectionOption> createState() => _FieldSelectionOptionState();
}

class _FieldSelectionOptionState extends State<FieldSelectionOption> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: AppStyles.lightGrey,
              ),
              child: Radio<String>(
                value: widget.field,
                groupValue: widget.groupValue,
                onChanged: (value) {
                  widget.onChanged(value);
                },
                activeColor: AppStyles.primaryTeal,
              ),
            ),
            Icon(
              widget.icon,
              size: 25,
              color: AppStyles.mediumGray,
            ),
            Container(
              child: Text(
                widget.field,
                style: GoogleFonts.poppins(
                    color: AppStyles.mediumGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1),
              ),
            ),
          ],
        ));
  }
}
