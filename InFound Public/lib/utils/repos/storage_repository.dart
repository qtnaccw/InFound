import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infound/utils/app_helpers.dart';

class StorageRepository extends GetxController {
  static StorageRepository get instance => Get.find();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(
      {required Uint8List bytes, required String path, required String imageName, required String contentType}) async {
    try {
      final Reference ref = _storage.ref().child(path + '/' + imageName);
      await ref
          .putData(bytes, contentType != '' ? SettableMetadata(contentType: contentType) : null)
          .whenComplete(() => printDebug('${path + '/' + imageName} Uploaded'));
      final url = await ref.getDownloadURL();
      return url;
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

  Future<void> deleteImage({required String path, required String imageName}) async {
    try {
      final Reference ref = _storage.ref().child(path + '/' + imageName);
      await ref.delete().whenComplete(() => printDebug('${path + '/' + imageName} Deleted'));
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
