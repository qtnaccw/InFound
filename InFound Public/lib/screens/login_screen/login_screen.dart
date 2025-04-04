import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/screens/login_screen/login_controller.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController(), tag: 'LoginController');

  @override
  void initState() {
    super.initState();
    waitForValue<UserModel>(() => AuthenticationRepository.instance.currentUserModel.value,
            timeout: Duration(seconds: 5))
        .then((val) {
      if (val != null) {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

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
            if (constraints.maxWidth > 1080) {
              return _buildWideContainers(constraints, size);
            } else {
              return _buildCompactContainers(constraints, size);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideContainers(BoxConstraints constraints, Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: size.height,
            color: AppStyles.primaryTeal,
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Opacity(
                    opacity: 0.25,
                    child: AppRoundedImage(
                      imageType: ImageType.asset,
                      image: AppConstants.iLoginGraphic,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(100),
                  alignment: Alignment.center,
                  child: Container(
                      constraints: BoxConstraints(maxHeight: 400),
                      child: SvgPicture.asset(AppConstants.iAppIconSimpleWhite)),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: size.height,
          constraints: BoxConstraints(
            minWidth: 720,
            maxWidth: 960,
          ),
          child: _loginPane(),
        )
      ],
    );
  }

  Widget _buildCompactContainers(BoxConstraints constraints, Size size) {
    return Row(
      children: [
        Expanded(
            child: Container(
          height: size.height,
          width: size.width,
          child: _loginPane(),
        )),
      ],
    );
  }

  Widget _loginPane() {
    final controller = Get.find<LoginController>(tag: 'LoginController');
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          padding: (constraints.maxWidth / constraints.maxHeight > 0.8)
              ? EdgeInsets.symmetric(vertical: 40, horizontal: 80)
              : EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.home);
                    },
                    child: Container(
                      height: 48,
                      width: constraints.maxWidth,
                      child: SvgPicture.asset(
                        AppConstants.iAppIconFullColored,
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 60, bottom: 40),
                    width: constraints.maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Looking for an item?',
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryTeal, fontSize: 40, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '''Don't let it get washed away.''',
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryBlack, fontSize: 80, fontWeight: FontWeight.w700, height: 1),
                        ),
                      ],
                    )),
                Container(
                  constraints: BoxConstraints(maxWidth: 350),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Join today.',
                      style: GoogleFonts.poppins(
                          color: AppStyles.primaryTealDarkest, fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    GoogleSignInButton(),
                  ]),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({
    super.key,
  });
  final controller = Get.find<LoginController>(tag: 'LoginController');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [AppStyles().lightBoxShadow(AppStyles.primaryTeal.withAlpha(100))],
      ),
      child: Material(
        color: AppStyles.pureWhite,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: () {
            controller.login(context);
          },
          borderRadius: BorderRadius.circular(32),
          hoverColor: AppStyles.primaryTealLightest,
          splashColor: AppStyles.primaryTealLighter,
          highlightColor: AppStyles.primaryTealLighter,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  child: CircleAvatar(
                    backgroundColor: AppStyles.primaryTeal,
                    child: Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: AppStyles.pureWhite,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(right: 18),
                ),
                Expanded(
                    child: Text(
                  'Sign in with Google.',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: AppStyles.primaryBlack, fontSize: 18, fontWeight: FontWeight.w500),
                )),
                Container(
                  height: 44,
                  width: 44,
                  padding: EdgeInsets.all(8),
                  child: SvgPicture.asset(AppConstants.iGoogleIcon),
                  margin: EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
