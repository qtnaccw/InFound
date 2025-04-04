import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
import 'package:infound/screens/admin_dashboard/admin_dashboard_screen.dart';
import 'package:infound/screens/bookmarks_screen/bookmarks_screen.dart';
import 'package:infound/screens/detail_screen/detail_screen.dart';
import 'package:infound/screens/home_screen/home_screen.dart';
import 'package:infound/screens/login_screen/login_screen.dart';
import 'package:infound/screens/login_screen/setup_screen.dart';
import 'package:infound/screens/notifications_screen/notifications_screen.dart';
import 'package:infound/screens/profile_screen/profile_screen.dart';
import 'package:infound/screens/search_screen/search_screen.dart';
import 'package:infound/screens/settings_screen/settings_screen.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/repos/authentication_repository.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const userSetup = '/setup';
  static const postWithID = '/post/:postID';
  static const profileWithID = '/profile/:username';
  static const bookmarks = '/bookmarks';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const admin = '/dashboard';
  static const search = '/search';
  static const searchWithQuery = '/search?query=:query';
  static const unknown = '/404';

  static final GetPage unknownPage = GetPage(name: unknown, page: () => HomeScreen());
  static final List<GetPage> pages = [
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(
      name: userSetup,
      page: () => SetupScreen(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(name: postWithID, page: () => DetailScreen()),
    GetPage(name: profileWithID, page: () => ProfileScreen()),
    GetPage(name: search, page: () => SearchScreen()),
    GetPage(name: searchWithQuery, page: () => SearchScreen()),
    GetPage(
      name: bookmarks,
      page: () => BookmarksScreen(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => NotificationsScreen(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => SettingsScreen(),
      middlewares: [AppMiddleware()],
    ),
    GetPage(
      name: admin,
      page: () => AdminDashboardScreen(),
      middlewares: [AppMiddleware()],
    ),
  ];
}

class AppMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    printDebug("isAuthenticated: ${AuthenticationRepository.instance.authUser}");
    return AuthenticationRepository.instance.isAuthenticated ? null : RouteSettings(name: AppRoutes.login);
  }
}
