import 'package:infound/utils/styles.dart';

class AppConstants {
  static const String tAppName = "in.found";
  static const String iLoginGraphic = "assets/images/login-graphic.png";

  static const String iAppIconFullBlack = "assets/icons/IconFullBlack.svg";
  static const String iAppIconFullColored = "assets/icons/IconFullColored.svg";
  static const String iAppIconFullWhite = "assets/icons/IconFullWhite.svg";
  static const String iAppIconSimpleBlack = "assets/icons/IconSimpleBlack.svg";
  static const String iAppIconSimpleColored = "assets/icons/IconSimpleColored.svg";
  static const String iAppIconSimpleWhite = "assets/icons/IconSimpleWhite.svg";
  static const String iGoogleIcon = "assets/icons/google-icon.svg";
  static const String tLoremIpsum =
      '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras non volutpat mauris, ut vestibulum velit. Maecenas eleifend lacinia nunc eget interdum. Phasellus nec nunc tempor, tristique enim sit amet, luctus tortor. Morbi mattis mauris sem, nec pellentesque sapien sagittis vitae. Sed purus purus, posuere non ex vel, dignissim dignissim neque. Mauris feugiat, justo vel laoreet luctus, est arcu tincidunt lacus, vel finibus libero purus in erat. Aenean ac interdum orci, et dapibus ante. Aliquam fringilla magna ligula, non ultricies justo egestas sit amet. Proin dui odio, condimentum et ornare id, lobortis et lorem. Morbi gravida sagittis lectus et luctus. Phasellus bibendum enim eget magna tincidunt cursus. Nam sit amet maximus massa, ac pretium augue.''';
  static const String tImageProvider = "https://yavuzceliker.github.io/sample-images/image-";
  static const String aInFoundLoader = "assets/animations/infound_loader.json";
  static const Map<String, dynamic> lPostTypes = {
    'LOST': AppStyles.primaryRed,
    'FOUND': AppStyles.primaryYellow,
    'GENERAL': AppStyles.primaryTeal,
  };
  static const Map<String, dynamic> lBadgeTypes = {
    'BRONZE': AppStyles.primaryBronze,
    'SILVER': AppStyles.primarySilver,
    'GOLD': AppStyles.primaryGold,
    'PLATINUM': AppStyles.primaryPlatinum,
    'DIAMOND': AppStyles.primaryDiamond,
  };
  static const int nLimitPosts = 10;
  static const int nLimitNotifications = 15;
  static const int nLimitReports = 10;
  static const int nLimitBadges = 15;
  static const int nLimitUserRequests = 15;
  static const int nLimitComments = 5;
  static const int nLimitReplies = 5;
  static const double navbarWidth = 320;
  static const double bodyMaxWidth = bodyWidth + 80;
  static const double bodyWidth = 600;
  static const double sidebarWidth = 400;
  static const double sidebarBreakpoint = navbarWidth + bodyMaxWidth + sidebarWidth;
  static const double navbarBreakpoint = 320 + bodyMaxWidth;
  static const String tCommentSeparator = '?commentId=';
  static const String tReplySeparator = '?replyId=';
  static const List<String> lReportTypes = [
    'Spam or Scam',
    'False Information',
    'Inappropriate Content',
    'Harassment or Bullying',
    'Hate Speech',
    'Impersonation',
    'Personal Information Sharing',
    'Copyright Violation',
    'Malicious Links or Malware',
    'Off-Topic or Irrelevant',
    'Duplicate Content',
  ];
}
