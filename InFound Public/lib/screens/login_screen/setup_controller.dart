import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/notification_service.dart';
import 'package:infound/utils/routes.dart';
import 'package:provider/provider.dart';

class SetupController extends GetxController {
  static SetupController get instance => Get.find();
  late TextEditingController usernameController;
  var usernameResult = ''.obs;

  RxBool privacyPolicyAccepted = false.obs;

  Future<bool> checkUsername(String username) async {
    if (username.isEmpty) {
      usernameResult.value = '';
      return false;
    }
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return false;
    }
    try {
      bool isAvail = await DatabaseRepository.instance.checkUsernameAvailability(username: username);
      if (isAvail) {
        usernameResult.value = 'Username is available';
        return false;
      } else {
        usernameResult.value = 'Username already taken';
        return true;
      }
    } catch (e) {
      AppPopups.customToast(message: 'An error occurred. Please try again.');
      return false;
    }
  }

  Future<void> setupUser(BuildContext context) async {
    if (!privacyPolicyAccepted.value) {
      AppPopups.customToast(message: 'Please accept the privacy policy to continue.');
      return;
    }

    AppPopups.openLoadingDialog("Setting up your account...", AppConstants.aInFoundLoader);
    final isConnected = await NetworkManager.instance.isConnected();

    if (!isConnected) {
      AppPopups.closeDialog();
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    try {
      UserModel newUser = UserModel(
          uid: AuthenticationRepository.instance.authUser!.uid,
          userName: usernameController.text,
          email: AuthenticationRepository.instance.authUser!.email!,
          isEmailPublic: false,
          bio: '',
          name: AuthenticationRepository.instance.authUser!.displayName!,
          profileURL: AuthenticationRepository.instance.authUser!.photoURL ?? '',
          isNamePublic: false,
          phone: AuthenticationRepository.instance.authUser!.phoneNumber ?? '',
          isPhonePublic: false,
          location: '',
          isLocationPublic: false,
          isVerified: false,
          isAdmin: false,
          posts: [],
          comments: [],
          replies: [],
          notifications: [],
          upvotes: [],
          bookmarks: [],
          badges: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      await DatabaseRepository.instance.createUser(user: newUser).then((value) async {
        UserModel? userLoaded =
            await DatabaseRepository.instance.getUserInfo(id: AuthenticationRepository.instance.authUser!.uid);
        AuthenticationRepository.instance.currentUserModel.value = userLoaded;
        AppPopups.closeDialog();
        Provider.of<NotificationService>(context, listen: false).listenForNotifications();
        Get.offAllNamed(AppRoutes.home);
        AppPopups.openUserGuidelines();
      }, onError: (value) {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(title: '[PROCESS] Error', message: "Unable to create user record. Please try again.");
      });
    } catch (e) {
      AppPopups.closeDialog();
      AppPopups.customToast(message: 'An error occurred. Please try again.');
    }
  }

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    usernameController.dispose();
  }
}
