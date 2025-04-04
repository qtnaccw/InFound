import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  Rx<UserModel?> currentUserModel = Rx<UserModel?>(null);
  RxList<String> currentUserBookmarks = <String>[].obs;
  Rx<bool?> loadUserDone = Rx<bool?>(null);

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    _auth.setPersistence(Persistence.LOCAL);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? loginTimestamp = prefs.getInt('login_timestamp');
    if (loginTimestamp != null) {
      DateTime loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      DateTime currentTime = DateTime.now();

      if (currentTime.difference(loginTime).inDays >= 7) {
        await _auth.signOut();
        if (_auth.currentUser != null) _auth.currentUser!.delete();
        await prefs.remove('login_timestamp');
      } else {
        if (_auth.currentUser != null) {
          try {
            currentUserModel.value = await DatabaseRepository.instance.getUserInfo(id: _auth.currentUser!.uid);
          } catch (e) {
            AppPopups.errorSnackBar(
                title: 'Error', message: "Error occurred while fetching user data. Please reload page and try again.");
          }
        }
      }
    } else {
      await _auth.signOut();
      if (_auth.currentUser != null) _auth.currentUser!.delete();
    }
    loadUserDone.value = true;
  }

  @override
  void onReady() async {
    super.onReady();
    ever(currentUserModel, (UserModel? updatedUser) {
      if (updatedUser != null) {
        currentUserBookmarks.assignAll(updatedUser.bookmarks);
      } else {
        currentUserBookmarks.clear();
      }
    });
  }

  // void screenRedirect() {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     Get.offAllNamed(AppRoutes.home);
  //   } else {
  //     Get.offAllNamed(AppRoutes.login);
  //   }
  // }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential googleCredentials = await _auth.signInWithPopup(GoogleAuthProvider());
      if (googleCredentials.user != null) {
        printDebug("Signed in as ${googleCredentials.user!.displayName} (${googleCredentials.user!.email})");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
        return googleCredentials;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      throw "[AUTH] Error" + ' : ' + e.message!;
    } on FirebaseException catch (e) {
      throw "[FIREBASE] Error" + ' : ' + e.message!;
    } on FormatException catch (e) {
      throw "[FORMAT] Error" + ' : ' + e.message;
    } on PlatformException catch (e) {
      throw "[PLATFORM] Error" + ' : ' + e.message!;
    } catch (e) {
      throw "[UNKNOWN] Error" + ' : ' + e.toString();
    }
  }

  Future<bool> signOut() async {
    try {
      if (_auth.currentUser == null) {
        currentUserModel.value = null;
        return false;
      }
      AppPopups.openLoadingDialog('Signing you out...', AppConstants.aInFoundLoader);
      await _auth.signOut().then((value) {
        if (_auth.currentUser != null) _auth.currentUser!.delete();
        currentUserModel.value = null;
      });
      AppPopups.closeDialog();
      return true;
    } on FirebaseAuthException catch (e) {
      throw "[AUTH] Error" + ' : ' + e.message!;
    } on FirebaseException catch (e) {
      throw "[FIREBASE] Error" + ' : ' + e.message!;
    } on FormatException catch (e) {
      throw "[FORMAT] Error" + ' : ' + e.message;
    } on PlatformException catch (e) {
      throw "[PLATFORM] Error" + ' : ' + e.message!;
    } catch (e) {
      throw "[UNKNOWN] Error" + ' : ' + e.toString();
    }
  }
}
