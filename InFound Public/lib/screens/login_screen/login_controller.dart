import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/routes.dart';
import 'package:provider/provider.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  Future login(BuildContext context) async {
    AppPopups.openLoadingDialog("Connecting to Google servers...", AppConstants.aInFoundLoader);
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.closeDialog();
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    try {
      UserCredential? google = await AuthenticationRepository.instance.signInWithGoogle();
      if (google != null) {
        if (AuthenticationRepository.instance.authUser != null) {
          String? userExists = await DatabaseRepository.instance
              .checkUserRecordExist(email: AuthenticationRepository.instance.authUser!.email!);
          if (userExists == null) {
            printDebug("User does not exist. Routing to User Setup");
            Get.offAllNamed(AppRoutes.userSetup);
          } else {
            AppPopups.openLoadingDialog("Getting your account info...", AppConstants.aInFoundLoader);
            UserModel? user = await DatabaseRepository.instance.getUserInfo(id: userExists);
            AuthenticationRepository.instance.currentUserModel.value = user;
            printDebug("User found.\n\n${user!.toJson()}\n\nRouting to Home");
            AppPopups.closeDialog();
            Get.offAllNamed(AppRoutes.home);
            Provider.of<NotificationService>(context, listen: false).listenForNotifications();

            AppPopups.openUserGuidelines();
          }
        } else {
          AppPopups.closeDialog();
          AppPopups.customToast(message: 'Unable to login. Please try again.');
          return;
        }
      } else {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(title: "[AUTHENTICATION] Error", message: "Authentication failed. Please try again.");
        return;
      }
    } catch (e) {
      AppPopups.closeDialog();
      AppPopups.customToast(message: 'An error occurred while logging in. Please try again.');
    }
  }
}
