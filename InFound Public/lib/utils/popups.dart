import 'dart:async';
import 'dart:math';
import 'package:bulleted_list/bulleted_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/components/image_widgets.dart';
import 'package:infound/components/loaders.dart';
import 'package:infound/main.dart';
import 'package:infound/models/badge_model.dart';
import 'package:infound/models/post_model.dart';
import 'package:infound/models/report_model.dart';
import 'package:infound/models/user_model.dart';
import 'package:infound/models/user_request_model.dart';
import 'package:infound/screens/settings_screen/settings_screen.dart';
import 'package:infound/utils/app_helpers.dart';
import 'package:infound/utils/constants.dart';
import 'package:infound/utils/google_map_widget.dart';
import 'package:infound/utils/repos/authentication_repository.dart';
import 'package:infound/utils/repos/database_repository.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/repos/network_manager.dart';
import 'package:infound/utils/repos/storage_repository.dart';
import 'package:infound/utils/routes.dart';
import 'package:infound/utils/styles.dart';
import 'package:otp/otp.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AppPopups {
  static confirmDialog({
    String title = 'Title',
    String content = 'Are you sure?',
    String cancelText = 'Cancel',
    String confirmText = 'Yes',
    Color? accentColor,
    Color? confirmTextColor,
    Function()? onCancel,
    Function()? onConfirm,
  }) {
    showDialog(
      context: Get.overlayContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.poppins(
                color: accentColor ?? AppStyles.primaryTeal,
                fontWeight: FontWeight.w600),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(color: AppStyles.primaryBlack),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(
                cancelText,
                style: GoogleFonts.poppins(color: AppStyles.mediumGray),
              ),
            ),
            TextButton(
              onPressed: onConfirm,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    accentColor != null ? accentColor : AppStyles.primaryTeal),
              ),
              child: Text(
                confirmText,
                style: GoogleFonts.poppins(
                    color: confirmTextColor ?? AppStyles.pureWhite,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        width: 500,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppStyles.primaryTeal.withOpacity(0.9),
          ),
          child: Center(
              child: Text(message,
                  style: Theme.of(Get.context!).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static successSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(
      title,
      message,
      maxWidth: 600,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppStyles.primaryTeal,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle_outline_rounded,
          color: AppStyles.pureWhite),
    );
  }

  static notificationSnackbar({required title, message = '', duration = 5}) {
    Get.snackbar(
      title,
      message,
      maxWidth: 600,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: AppStyles.primaryTeal,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.notifications_active, color: AppStyles.pureWhite),
    );
  }

  static warningSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      maxWidth: 600,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppStyles.pureWhite,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning_amber_rounded, color: AppStyles.pureWhite),
    );
  }

  static errorSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      maxWidth: 600,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppStyles.pureWhite,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.error_outline_rounded, color: AppStyles.pureWhite),
    );
  }

  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context:
          Get.overlayContext!, // Use Get.overlayContext for overlay dialogs
      barrierDismissible:
          false, // The dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Material(
          child: Container(
            color: AppStyles.pureWhite,
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAnimationLoaderWidget(
                    text: text,
                    animation: animation,
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: AppStyles.primaryTealLighter,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void popUpCircular() {
    Get.defaultDialog(
      title: '',
      onWillPop: () async => false,
      content: const AppCircularLoader(),
      backgroundColor: Colors.transparent,
    );
  }

  static closeDialog() {
    Navigator.of(Get.overlayContext!)
        .pop(); // Close the dialog using the Navigator
  }

  static void openComposeBox({
    required String username,
    required String uid,
    required String profileURL,
    required bool isVerified,
    required bool isEditing,
    Function(PostModel)? onPost,
    Function(PostModel)? onEdit,
    String? ePostType,
    String? eTitle,
    String? eDescription,
    List<String>? eImages,
    String? eLocation,
    String? eItemColor,
    String? eItemSize,
    String? eItemBrand,
    String? ePostId,
    PostModel? ePost,
  }) {
    RxString postType = 'LOST'.obs;
    RxList<Uint8List> images = <Uint8List>[].obs;
    RxList<XFile> imagesXFile = <XFile>[].obs;
    RxBool withLocation = false.obs;
    double? latitude = null;
    double? longitude = null;
    double? radius = null;
    RxBool withDetails = false.obs;
    RxString location = ''.obs;
    RxBool isEditingTitle = false.obs;
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController itemColorController = TextEditingController();
    TextEditingController itemSizeController = TextEditingController();
    TextEditingController itemBrandController = TextEditingController();

    RxString currentTitle = "".obs;
    ScrollController scrollController = ScrollController();

    RxList<dynamic> editingImagesList = <dynamic>[].obs;
    RxList<dynamic> editingImagesListXFile = <dynamic>[].obs;

    if (isEditing) {
      postType.value = ePostType!;
      editingImagesList.assignAll(eImages ?? []);
      editingImagesListXFile.assignAll(eImages ?? []);
      titleController.text = eTitle ?? '';
      descriptionController.text = eDescription ?? '';
      currentTitle.value = eTitle ?? '';
      withLocation.value = eLocation != null && eLocation != '';
      location.value = eLocation ?? '';
      List<double> coords = eLocation != null && eLocation != ''
          ? AppFormatter.parseLocation(eLocation)
          : [];
      latitude = eLocation != null && eLocation != '' ? coords[0] : null;
      longitude = eLocation != null && eLocation != '' ? coords[1] : null;
      radius = eLocation != null && eLocation != '' ? coords[2] : null;
      itemColorController.text = eItemColor ?? '';
      itemSizeController.text = eItemSize ?? '';
      itemBrandController.text = eItemBrand ?? '';
      withDetails.value = (eItemColor != null && eItemColor != '') ||
          (eItemSize != null && eItemSize != '') ||
          (eItemBrand != null && eItemBrand != '');
    }

    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) {
        FocusNode titleNode = FocusNode();
        return PopScope(
          canPop: false, // Disable popping with the back button
          child: Container(
            margin: EdgeInsets.all(30),
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.topCenter,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                  constraints: BoxConstraints(
                    maxWidth: AppConstants.bodyWidth,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppStyles.pureWhite),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Header
                        Container(
                          width: double.infinity,
                          height: 40,
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(isEditing ? 'Edit' : 'Compose',
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppStyles.primaryBlack)),
                              )),
                              Container(
                                height: double.infinity,
                                width: 156,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            confirmDialog(
                                                title: isEditing
                                                    ? 'Discard edits'
                                                    : "Discard post",
                                                content: isEditing
                                                    ? 'Are you sure you want to discard edits on this post?'
                                                    : 'Are you sure you want to discard this post?',
                                                confirmText: 'Discard',
                                                accentColor:
                                                    AppStyles.primaryRed,
                                                onConfirm: () {
                                                  isEditingTitle.value = false;
                                                  titleController.dispose();
                                                  descriptionController
                                                      .dispose();
                                                  itemColorController.dispose();
                                                  itemSizeController.dispose();
                                                  itemBrandController.dispose();
                                                  closeDialog();
                                                  closeDialog();
                                                });
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppStyles.mediumGray),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Container(
                                      width: 80,
                                      height: double.infinity,
                                      child: MaterialButtonIcon(
                                        onTap: () async {
                                          final isConnected =
                                              await NetworkManager.instance
                                                  .isConnected();

                                          if (!isConnected) {
                                            AppPopups.customToast(
                                                message:
                                                    'No Internet Connection');
                                            return;
                                          }

                                          if (titleController.text == '') {
                                            isEditingTitle.value = false;
                                            AppPopups.warningSnackBar(
                                                title: 'Title required',
                                                message:
                                                    'Please provide a title for your post.');
                                            return;
                                          }
                                          if (descriptionController.text ==
                                              '') {
                                            AppPopups.warningSnackBar(
                                                title: 'Description required',
                                                message:
                                                    'Please provide a description for your post.');
                                            return;
                                          }
                                          if (!isEditing) {
                                            //Upload images
                                            AppPopups.openLoadingDialog(
                                                "Creating your post...",
                                                AppConstants.aInFoundLoader);
                                            String postId = uuid.v1();
                                            final storageRepository =
                                                Get.put(StorageRepository());
                                            List<String> imagePaths = [];
                                            if (imagesXFile.isNotEmpty) {
                                              for (int i = 0;
                                                  i < imagesXFile.length;
                                                  i++) {
                                                var imageBytes =
                                                    await imagesXFile[i]
                                                        .readAsBytes();
                                                imagePaths.add(await storageRepository
                                                    .uploadImage(
                                                        bytes: imageBytes,
                                                        path: 'posts/${postId}',
                                                        imageName:
                                                            "${postId}-image-${i}.${getFileExtension(imagesXFile[i])}",
                                                        contentType:
                                                            imagesXFile[i]
                                                                    .mimeType ??
                                                                ''));
                                              }
                                            }
                                            if (imagePaths.length !=
                                                imagesXFile.length) {
                                              AppPopups.closeDialog();
                                              AppPopups.errorSnackBar(
                                                  title: 'Image upload failed',
                                                  message:
                                                      'Failed to upload images. Please try again.');
                                              return;
                                            } else {
                                              PostModel newPost = PostModel(
                                                  postId: postId,
                                                  userId: uid,
                                                  type: postType.value,
                                                  title: titleController.text,
                                                  description:
                                                      descriptionController
                                                          .text,
                                                  location: location.value,
                                                  latitude: latitude,
                                                  longitude: longitude,
                                                  radius: radius,
                                                  itemColor:
                                                      itemColorController.text,
                                                  itemSize:
                                                      itemSizeController.text,
                                                  itemBrand:
                                                      itemBrandController.text,
                                                  imagesURL: imagePaths,
                                                  numUpvotes: 0,
                                                  numComments: 0,
                                                  comments: [],
                                                  commentsId: [],
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now());
                                              await DatabaseRepository.instance
                                                  .createPost(post: newPost)
                                                  .then((value) {
                                                AppPopups.closeDialog();
                                                AppPopups.closeDialog();
                                                if (onPost != null)
                                                  onPost(newPost);
                                              });
                                            }
                                          }
                                          if (isEditing) {
                                            AppPopups.openLoadingDialog(
                                                "Updating post...",
                                                AppConstants.aInFoundLoader);
                                            final storageRepository =
                                                Get.put(StorageRepository());
                                            List<String> imagePaths = [];
                                            if (editingImagesListXFile
                                                .isNotEmpty) {
                                              for (int i = 0;
                                                  i <
                                                      editingImagesListXFile
                                                          .length;
                                                  i++) {
                                                if (editingImagesListXFile[i]
                                                    is XFile) {
                                                  var imageBytes =
                                                      await editingImagesListXFile[
                                                              i]
                                                          .readAsBytes();
                                                  imagePaths.add(await storageRepository.uploadImage(
                                                      bytes: imageBytes,
                                                      path:
                                                          'posts/${ePost!.postId}',
                                                      imageName:
                                                          "${ePost.postId}-image-${i}.${getFileExtension(editingImagesListXFile[i])}",
                                                      contentType:
                                                          editingImagesListXFile[
                                                                      i]
                                                                  .mimeType ??
                                                              ''));
                                                }
                                                if (editingImagesListXFile[i]
                                                    is String) {
                                                  imagePaths.add(
                                                      editingImagesListXFile[
                                                          i]);
                                                }
                                              }
                                            }
                                            if (imagePaths.length !=
                                                editingImagesListXFile.length) {
                                              AppPopups.closeDialog();
                                              AppPopups.errorSnackBar(
                                                  title: 'Image upload failed',
                                                  message:
                                                      'Failed to upload images. Please try again.');
                                              return;
                                            } else {
                                              PostModel newPost = ePost!
                                                  .copyWith(
                                                      type: postType.value,
                                                      title:
                                                          titleController.text,
                                                      description:
                                                          descriptionController
                                                              .text,
                                                      location: location.value,
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                      radius: radius,
                                                      itemColor:
                                                          itemColorController
                                                              .text,
                                                      itemSize:
                                                          itemSizeController
                                                              .text,
                                                      itemBrand:
                                                          itemBrandController
                                                              .text,
                                                      imagesURL: imagePaths,
                                                      updatedAt:
                                                          DateTime.now());
                                              await DatabaseRepository.instance
                                                  .updatePost(post: newPost)
                                                  .then((value) {
                                                AppPopups.closeDialog();
                                                AppPopups.closeDialog();
                                                if (onEdit != null)
                                                  onEdit(newPost);
                                              });
                                            }
                                          }
                                        },
                                        withText: true,
                                        withIcon: false,
                                        text: isEditing ? 'Update' : "Post",
                                        buttonColor: AppStyles.primaryTeal,
                                        highlightColor:
                                            AppStyles.primaryTealDarker,
                                        splashColor:
                                            AppStyles.primaryTealDarkest,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Body
                        Flexible(
                            child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: SingleChildScrollView(
                              child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //Profile
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 6),
                                        height: 44,
                                        width: 44,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: AppStyles.pureWhite,
                                          boxShadow: [
                                            AppStyles().lightBoxShadow(AppStyles
                                                .primaryBlack
                                                .withAlpha(150))
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: profileURL != ''
                                            ? Container(
                                                height: 35,
                                                width: 35,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: AppRoundedImage(
                                                    imageType:
                                                        ImageType.network,
                                                    image: profileURL,
                                                    fit: BoxFit.cover),
                                              )
                                            : Icon(
                                                Icons.account_circle_outlined,
                                                size: 42,
                                                color: AppStyles
                                                    .primaryTealLighter,
                                              ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          padding: EdgeInsets.only(top: 6),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        username,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 18,
                                                                color: AppStyles
                                                                    .primaryBlack,
                                                                height: 1.25),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 2),
                                                      child: Icon(
                                                        Icons.verified,
                                                        color: AppStyles
                                                            .primaryTeal,
                                                        size: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                'Just now',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: AppStyles.lightGrey,
                                                    height: 1.25),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //Title
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
                                  margin: EdgeInsets.only(top: 12),
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return Obx(
                                      () => Text.rich(
                                        style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: AppStyles.primaryBlack,
                                            height: 1),
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                                child: Transform.translate(
                                              offset: Offset(0, -2),
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 4),
                                                width: 80,
                                                child: Obx(() {
                                                  return DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      items: (AppConstants
                                                              .lPostTypes.keys
                                                              .toList())
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppConstants
                                                                      .lPostTypes[
                                                                  value],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                            child: Text(
                                                              value,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppStyles
                                                                    .pureWhite,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        postType.value = value!;
                                                      },
                                                      selectedItemBuilder:
                                                          (context) =>
                                                              (AppConstants
                                                                      .lPostTypes
                                                                      .keys
                                                                      .toList())
                                                                  .map((String
                                                                      value) {
                                                        return Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2,
                                                                  horizontal:
                                                                      6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppConstants
                                                                    .lPostTypes[
                                                                value],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            value,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppStyles
                                                                  .pureWhite,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      elevation: 8,
                                                      iconSize: 14,
                                                      value: postType.value,
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      isDense: true,
                                                      isExpanded: true,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      // icon: Container(),
                                                      dropdownColor:
                                                          AppStyles.pureWhite,
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )),
                                            if (!isEditingTitle.value &&
                                                currentTitle.value != '')
                                              TextSpan(
                                                text: currentTitle.value,
                                                mouseCursor:
                                                    SystemMouseCursors.text,
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        isEditingTitle.value =
                                                            true;
                                                      },
                                              ),
                                            if (!isEditingTitle.value &&
                                                currentTitle.value == '')
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Title goes here',
                                                    mouseCursor:
                                                        SystemMouseCursors.text,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            isEditingTitle
                                                                .value = true;
                                                            titleNode
                                                                .requestFocus();
                                                          },
                                                  ),
                                                  TextSpan(
                                                    text: '*',
                                                    style: GoogleFonts.poppins(
                                                        color: AppStyles
                                                            .primaryRed),
                                                    mouseCursor:
                                                        SystemMouseCursors.text,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            isEditingTitle
                                                                .value = true;
                                                            titleController
                                                                    .selection =
                                                                TextSelection
                                                                    .fromPosition(
                                                              TextPosition(
                                                                  offset:
                                                                      titleController
                                                                          .text
                                                                          .length),
                                                            );
                                                          },
                                                  ),
                                                ],
                                              ),
                                            if (isEditingTitle.value)
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.top,
                                                child: Container(
                                                  width:
                                                      constraints.maxWidth - 96,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 1),
                                                          child:
                                                              IntrinsicHeight(
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minHeight:
                                                                          24),
                                                              child: TextField(
                                                                focusNode:
                                                                    titleNode,
                                                                controller:
                                                                    titleController,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppStyles
                                                                        .primaryBlack,
                                                                    height: 1),
                                                                maxLines: null,
                                                                expands: true,
                                                                decoration: InputDecoration.collapsed(
                                                                    hintText:
                                                                        "Title goes here*",
                                                                    hintStyle: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: AppStyles
                                                                            .lightGrey,
                                                                        height:
                                                                            1)),
                                                                onChanged:
                                                                    (value) {
                                                                  currentTitle
                                                                          .value =
                                                                      value;
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 8),
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppStyles
                                                              .primaryTeal,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: IconButton(
                                                          hoverColor: AppStyles
                                                              .primaryTealDarker,
                                                          focusColor: AppStyles
                                                              .primaryTealDarker,
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          iconSize: 20,
                                                          icon: Icon(
                                                            Icons.check_rounded,
                                                            size: 20,
                                                            color: AppStyles
                                                                .pureWhite,
                                                          ),
                                                          onPressed: () {
                                                            isEditingTitle
                                                                .value = false;
                                                          },
                                                          highlightColor: AppStyles
                                                              .primaryTealDarker,
                                                          splashColor: AppStyles
                                                              .primaryTealDarker,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                //Description
                                Flexible(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      // constraints: BoxConstraints(minHeight: 50, maxHeight: 500),
                                      padding: EdgeInsets.only(
                                          left: 16,
                                          right: 8,
                                          top: 8,
                                          bottom: 8),
                                      child: Container(
                                        constraints:
                                            BoxConstraints(minHeight: 24),
                                        child: TextField(
                                          style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: AppStyles.primaryBlack),
                                          maxLines: null,
                                          expands: true,
                                          decoration: InputDecoration.collapsed(
                                              hintText: "Description",
                                              hintStyle: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: AppStyles.mediumGray)),
                                          controller: descriptionController,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //Location
                                Obx(
                                  () =>
                                      (withLocation.value || withDetails.value)
                                          ? Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.only(
                                                  left: 24, bottom: 8),
                                              child: Column(
                                                children: [
                                                  if (withDetails.value) ...[
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4),
                                                                  child: Icon(
                                                                    Icons
                                                                        .color_lens_outlined,
                                                                    color: AppStyles
                                                                        .lightGrey,
                                                                    size: 16,
                                                                  )),
                                                              Text(
                                                                "Color: ",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    height: 1.5,
                                                                    fontSize:
                                                                        14,
                                                                    color: AppStyles
                                                                        .lightGrey),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      IntrinsicHeight(
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              minHeight: 24),
                                                                      child:
                                                                          TextField(
                                                                        maxLines:
                                                                            null,
                                                                        expands:
                                                                            true,
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              200),
                                                                        ],
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AppStyles.primaryTeal),
                                                                        decoration: InputDecoration.collapsed(
                                                                            hintText:
                                                                                "Describe the item/s' color",
                                                                            hintStyle:
                                                                                GoogleFonts.roboto(fontSize: 14, color: AppStyles.lightGrey)),
                                                                        controller:
                                                                            itemColorController,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])),
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4),
                                                                  child: Icon(
                                                                    Icons
                                                                        .format_line_spacing_outlined,
                                                                    color: AppStyles
                                                                        .lightGrey,
                                                                    size: 16,
                                                                  )),
                                                              Text(
                                                                "Size: ",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    height: 1.5,
                                                                    fontSize:
                                                                        14,
                                                                    color: AppStyles
                                                                        .lightGrey),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      IntrinsicHeight(
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              minHeight: 24),
                                                                      child:
                                                                          TextField(
                                                                        maxLines:
                                                                            null,
                                                                        expands:
                                                                            true,
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              200),
                                                                        ],
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AppStyles.primaryTeal),
                                                                        decoration: InputDecoration.collapsed(
                                                                            hintText:
                                                                                "Describe the item/s' size",
                                                                            hintStyle:
                                                                                GoogleFonts.roboto(fontSize: 14, color: AppStyles.lightGrey)),
                                                                        controller:
                                                                            itemSizeController,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])),
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4),
                                                                  child: Icon(
                                                                    Icons
                                                                        .loyalty_outlined,
                                                                    color: AppStyles
                                                                        .lightGrey,
                                                                    size: 16,
                                                                  )),
                                                              Text(
                                                                "Brand: ",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    height: 1.5,
                                                                    fontSize:
                                                                        14,
                                                                    color: AppStyles
                                                                        .lightGrey),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      IntrinsicHeight(
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              minHeight: 24),
                                                                      child:
                                                                          TextField(
                                                                        maxLines:
                                                                            null,
                                                                        expands:
                                                                            true,
                                                                        inputFormatters: [
                                                                          LengthLimitingTextInputFormatter(
                                                                              200),
                                                                        ],
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AppStyles.primaryTeal),
                                                                        decoration: InputDecoration.collapsed(
                                                                            hintText:
                                                                                "Specify the item/s' brand",
                                                                            hintStyle:
                                                                                GoogleFonts.roboto(fontSize: 14, color: AppStyles.lightGrey)),
                                                                        controller:
                                                                            itemBrandController,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])),
                                                  ],
                                                  if (withLocation.value)
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              4),
                                                                  child: Icon(
                                                                    Icons
                                                                        .location_on_outlined,
                                                                    color: AppStyles
                                                                        .lightGrey,
                                                                    size: 16,
                                                                  )),
                                                              Text(
                                                                "Location: ",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts.roboto(
                                                                    fontSize:
                                                                        14,
                                                                    color: AppStyles
                                                                        .lightGrey),
                                                              ),
                                                              Obx(
                                                                () => Expanded(
                                                                    child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          MouseRegion(
                                                                        cursor:
                                                                            SystemMouseCursors.click,
                                                                        child: GestureDetector(
                                                                            onTap: () {
                                                                              AppPopups.openMapPicker(
                                                                                  currentLatitude: latitude,
                                                                                  currentLongitude: longitude,
                                                                                  currentRadius: radius,
                                                                                  onSubmit: (address, coordinates) {
                                                                                    location.value = address;
                                                                                    String coord = coordinates.toString().replaceAll('(', '').replaceAll(')', '').replaceAll('m', '');
                                                                                    List<String> coords = coord.split(', ');
                                                                                    latitude = double.parse(coords[0]);
                                                                                    longitude = double.parse(coords[1]);
                                                                                    radius = double.parse(coords[2]);
                                                                                  });
                                                                            },
                                                                            child: Text(
                                                                              location.value == '' ? 'Set location' : location.value,
                                                                              style: GoogleFonts.roboto(fontSize: 14, color: AppStyles.primaryTeal),
                                                                            )),
                                                                      ),
                                                                    ),
                                                                    if (location
                                                                            .value !=
                                                                        '')
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            right:
                                                                                8,
                                                                            left:
                                                                                16),
                                                                        child:
                                                                            TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            location.value =
                                                                                '';
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Remove',
                                                                            style:
                                                                                GoogleFonts.roboto(fontSize: 14, color: AppStyles.primaryRed),
                                                                          ),
                                                                        ),
                                                                      )
                                                                  ],
                                                                )),
                                                              ),
                                                            ])),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                ),
                                Obx(
                                  () => !isEditing
                                      ? images.isNotEmpty
                                          ? Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 8),
                                              width: double.infinity,
                                              height: 208,
                                              child: Scrollbar(
                                                thickness: 4,
                                                thumbVisibility: true,
                                                interactive: true,
                                                controller: scrollController,
                                                child: Obx(
                                                  () => ReorderableListView(
                                                    onReorder: (int oldIndex,
                                                        int newIndex) {
                                                      if (oldIndex < newIndex) {
                                                        newIndex -= 1;
                                                      }
                                                      final Uint8List item =
                                                          images.removeAt(
                                                              oldIndex);
                                                      final XFile itemXFile =
                                                          imagesXFile.removeAt(
                                                              oldIndex);
                                                      images.insert(
                                                          newIndex, item);
                                                      imagesXFile.insert(
                                                          newIndex, itemXFile);
                                                    },
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    scrollController:
                                                        scrollController,
                                                    children: [
                                                      for (int i = 0;
                                                          i < images.length;
                                                          i++)
                                                        Container(
                                                          key: ValueKey(i),
                                                          width: 160,
                                                          height: 160,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          margin:
                                                              EdgeInsets.all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            color: AppStyles
                                                                .pureWhite,
                                                            boxShadow: [
                                                              AppStyles().lightBoxShadow(
                                                                  AppStyles
                                                                      .primaryBlack
                                                                      .withAlpha(
                                                                          150))
                                                            ],
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: 160,
                                                                height: 160,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: AppRoundedImage(
                                                                    imageType:
                                                                        ImageType
                                                                            .memory,
                                                                    memoryImage:
                                                                        images[
                                                                            i],
                                                                    fit: BoxFit
                                                                        .contain),
                                                              ),
                                                              Positioned(
                                                                  top: 10,
                                                                  right: 10,
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppStyles
                                                                          .primaryBlack
                                                                          .withAlpha(
                                                                              80),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                    child:
                                                                        IconButton(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      iconSize:
                                                                          28,
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close_rounded,
                                                                        color: AppStyles
                                                                            .pureWhite,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        images.removeAt(
                                                                            i);
                                                                        imagesXFile
                                                                            .removeAt(i);
                                                                        images
                                                                            .refresh();
                                                                        imagesXFile
                                                                            .refresh();
                                                                      },
                                                                    ),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          : Container()
                                      : editingImagesList.isNotEmpty
                                          ? Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 8),
                                              width: double.infinity,
                                              height: 208,
                                              child: Scrollbar(
                                                thickness: 4,
                                                thumbVisibility: true,
                                                interactive: true,
                                                controller: scrollController,
                                                child: Obx(
                                                  () => ReorderableListView(
                                                    onReorder: (int oldIndex,
                                                        int newIndex) {
                                                      if (oldIndex < newIndex) {
                                                        newIndex -= 1;
                                                      }
                                                      var item =
                                                          editingImagesList
                                                              .removeAt(
                                                                  oldIndex);
                                                      var itemX =
                                                          editingImagesListXFile
                                                              .removeAt(
                                                                  oldIndex);
                                                      editingImagesList.insert(
                                                          newIndex, item);
                                                      editingImagesListXFile
                                                          .insert(
                                                              newIndex, itemX);
                                                    },
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    scrollController:
                                                        scrollController,
                                                    children: [
                                                      for (int i = 0;
                                                          i <
                                                              editingImagesList
                                                                  .length;
                                                          i++)
                                                        Container(
                                                          key: ValueKey(i),
                                                          width: 160,
                                                          height: 160,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          margin:
                                                              EdgeInsets.all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            color: AppStyles
                                                                .pureWhite,
                                                            boxShadow: [
                                                              AppStyles().lightBoxShadow(
                                                                  AppStyles
                                                                      .primaryBlack
                                                                      .withAlpha(
                                                                          150))
                                                            ],
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: 160,
                                                                height: 160,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: editingImagesList[i]
                                                                        is Uint8List
                                                                    ? AppRoundedImage(
                                                                        imageType:
                                                                            ImageType
                                                                                .memory,
                                                                        memoryImage:
                                                                            editingImagesList[
                                                                                i],
                                                                        fit: BoxFit
                                                                            .contain)
                                                                    : AppRoundedImage(
                                                                        imageType:
                                                                            ImageType
                                                                                .network,
                                                                        image: editingImagesList[
                                                                            i],
                                                                        fit: BoxFit
                                                                            .contain),
                                                              ),
                                                              Positioned(
                                                                  top: 10,
                                                                  right: 10,
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppStyles
                                                                          .primaryBlack
                                                                          .withAlpha(
                                                                              80),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                    child:
                                                                        IconButton(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      iconSize:
                                                                          28,
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close_rounded,
                                                                        color: AppStyles
                                                                            .pureWhite,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        editingImagesList
                                                                            .removeAt(i);
                                                                        editingImagesListXFile
                                                                            .removeAt(i);
                                                                        editingImagesList
                                                                            .refresh();
                                                                        editingImagesListXFile
                                                                            .refresh();
                                                                      },
                                                                    ),
                                                                  ))
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          : Container(),
                                ),
                              ],
                            ),
                          )),
                        )),
                        //Footer
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          width: double.infinity,
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 25,
                                          color: AppStyles.mediumGray,
                                        ),
                                        onPressed: () async {
                                          if (!isEditing) {
                                            if (images.length >= 10) {
                                              AppPopups.warningSnackBar(
                                                  title:
                                                      'Maximum images reached',
                                                  message:
                                                      'The maximum number of images allowed is 10.');
                                              return;
                                            }
                                            final ImagePicker _picker =
                                                ImagePicker();
                                            List<XFile>? selected =
                                                await _picker.pickMultiImage(
                                                    limit: 10 - images.length);
                                            if (selected.isNotEmpty) {
                                              for (int i = 0;
                                                  i < min(selected.length, 10);
                                                  i++) {
                                                images.add(await selected[i]
                                                    .readAsBytes());
                                                imagesXFile.add(selected[i]);
                                                images.refresh();
                                                imagesXFile.refresh();
                                              }
                                              if (selected.length > 10) {
                                                AppPopups.warningSnackBar(
                                                    title:
                                                        'Maximum images exceeded',
                                                    message:
                                                        'The maximum number of images allowed is 10.');
                                              }
                                            }
                                          } else {
                                            if (editingImagesList.length >=
                                                10) {
                                              AppPopups.warningSnackBar(
                                                  title:
                                                      'Maximum images reached',
                                                  message:
                                                      'The maximum number of images allowed is 10.');
                                              return;
                                            }
                                            final ImagePicker _picker =
                                                ImagePicker();
                                            List<XFile>? selected =
                                                await _picker.pickMultiImage(
                                                    limit: 10 -
                                                        editingImagesList
                                                            .length);
                                            if (selected.isNotEmpty) {
                                              for (int i = 0;
                                                  i < min(selected.length, 10);
                                                  i++) {
                                                editingImagesList.add(
                                                    await selected[i]
                                                        .readAsBytes());
                                                editingImagesListXFile
                                                    .add(selected[i]);
                                                editingImagesList.refresh();
                                                editingImagesListXFile
                                                    .refresh();
                                              }
                                              if (selected.length > 10) {
                                                AppPopups.warningSnackBar(
                                                    title:
                                                        'Maximum images exceeded',
                                                    message:
                                                        'The maximum number of images allowed is 10.');
                                              }
                                            }
                                          }
                                        },
                                        hoverColor:
                                            AppStyles.primaryTealLightest,
                                        highlightColor:
                                            AppStyles.primaryTealLightest,
                                        splashColor:
                                            AppStyles.primaryTealLighter,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.list_rounded,
                                          size: 25,
                                          color: AppStyles.mediumGray,
                                        ),
                                        onPressed: () {
                                          withDetails.value =
                                              !withDetails.value;
                                          if (!withDetails.value) {
                                            itemColorController.clear();
                                            itemSizeController.clear();
                                            itemBrandController.clear();
                                          }
                                        },
                                        hoverColor:
                                            AppStyles.primaryTealLightest,
                                        highlightColor:
                                            AppStyles.primaryTealLightest,
                                        splashColor:
                                            AppStyles.primaryTealLighter,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.add_location_alt_outlined,
                                          size: 25,
                                          color: AppStyles.mediumGray,
                                        ),
                                        onPressed: () {
                                          withLocation.value =
                                              !withLocation.value;
                                          if (!withLocation.value) {
                                            location.value = '';
                                          }
                                        },
                                        hoverColor:
                                            AppStyles.primaryTealLightest,
                                        highlightColor:
                                            AppStyles.primaryTealLightest,
                                        splashColor:
                                            AppStyles.primaryTealLighter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  })),
            ),
          ),
        );
      },
    );
  }

  static void openScrollablePopup({
    String? title,
    double maxWidth = AppConstants.bodyWidth,
    Alignment titleAlignment = Alignment.centerLeft,
    required Widget? body,
    required Widget? footer,
  }) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false, // Disable popping with the back button
          child: Container(
            margin: EdgeInsets.all(30),
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: Stack(
                    children: [
                      IntrinsicHeight(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppStyles.pureWhite),
                          margin: EdgeInsets.only(right: 12, top: 12),
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Header
                              Container(
                                width: double.infinity,
                                height: title != null ? 40 : 0,
                                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: title != null
                                    ? Row(
                                        children: [
                                          Expanded(
                                              child: Container(
                                            margin: EdgeInsets.only(left: 8),
                                            alignment: titleAlignment,
                                            child: Text(title,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppStyles
                                                        .primaryBlack)),
                                          )),
                                        ],
                                      )
                                    : Container(),
                              ),
                              //Body
                              Flexible(
                                child: IntrinsicHeight(
                                  child: Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(16, 8, 8, 8),
                                    child: SingleChildScrollView(
                                      child: Container(
                                          margin: EdgeInsets.only(right: 16),
                                          child: body),
                                    ),
                                  ),
                                ),
                              ),

                              //Footer
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                width: double.infinity,
                                child: IntrinsicHeight(child: footer),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                              color: AppStyles.primaryTeal,
                              borderRadius: BorderRadius.circular(16)),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppStyles.pureWhite,
                              size: 16,
                            ),
                            onPressed: () {
                              AppPopups.closeDialog();
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        );
      },
    );
  }

  static void openPrivacyStatement({bool firstTime = false}) {
    openScrollablePopup(
        title: 'InFound Privacy Policy',
        titleAlignment: Alignment.center,
        maxWidth: 500,
        body: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Effective Date: January 01, 2025',
              style:
                  GoogleFonts.roboto(color: AppStyles.lightGrey, fontSize: 12),
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text:
                                'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use '),
                        TextSpan(
                            text: 'InFound',
                            style: GoogleFonts.roboto(
                                color: AppStyles.primaryTeal,
                                fontWeight: FontWeight.w600)),
                        TextSpan(text: '.'),
                      ],
                    ),
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Information We Collect',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'When you use our app, we collect the following types of information:',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Personal Information: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'Your name, email address, phone number, and location (as provided by Google OAuth and any additional data you input).'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'User-Generated Content: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'Posts, comments, replies, photos, and other interactions within the app.'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Usage Data: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'Information about how you use the app, such as search queries, filters applied, and interactions with posts.'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Device Information: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'IP address, device type, operating system, and app version.'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'How We Use Your Information',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'We use the collected information to:',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text('Provide and personalize your app experience.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Allow you to create and manage posts effectively.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Facilitate communication and engagement within the community.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Notify you of activity related to your posts and interactions.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Improve app performance and user experience.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Ensure the security and integrity of the platform.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Data Sharing and Disclosure',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'We do not sell or share your personal information with third parties, except in the following cases:',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Service Providers: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'We may share data with trusted third-party vendors to provide essential app functionalities (e.g., Firebase for storage and authentication).'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Legal Compliance: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'If required by law or to protect the rights and safety of users.'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Community Reports: ',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    'In case of reported content, data may be reviewed by admins to ensure compliance with community guidelines.'),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Data Security',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'We take the security of your data seriously and implement measures such as:',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text('Authentication via Google OAuth for secure login.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Storage of data in a secured Firebase database.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Encryption and access control measures to protect information.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Privacy Choices',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'You have control over your information:',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text(
                          'Edit or delete your profile details through the Settings page.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Manage privacy settings to choose what information is public or private.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Delete your account to remove all your data from our system.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Third-Party Links',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these external platforms.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Changes to this Privacy Policy',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'We may update this Privacy Policy periodically. We will notify you of significant changes by posting an updated policy within the app.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Contact Us',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'If you have any questions or concerns about this Privacy Policy, please contact us at support@infound.com.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                ],
              )),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Thank you for trusting '),
                  TextSpan(
                      text: 'InFound',
                      style: GoogleFonts.roboto(
                          color: AppStyles.primaryTeal,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: '!'),
                ],
              ),
              style: GoogleFonts.roboto(
                  color: AppStyles.primaryBlack, fontSize: 14),
            ),
          ),
          SizedBox(height: 16),
        ])),
        footer: firstTime
            ? Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButtonIcon(
                      onTap: () {
                        AppPopups.closeDialog();
                      },
                      height: 40,
                      buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                      withIcon: false,
                      withText: true,
                      text: 'I understand',
                    ),
                  ],
                ),
              )
            : null);
  }

  static void openUserGuidelines({bool firstTime = false}) {
    openScrollablePopup(
        title: 'InFound User Guidelines',
        titleAlignment: Alignment.center,
        maxWidth: 500,
        body: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              child: SvgPicture.asset(AppConstants.iAppIconFullColored)),
          Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(
                            text: 'InFound',
                            style: GoogleFonts.roboto(
                                color: AppStyles.primaryTeal,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text:
                                ', your Lost & Found app! This platform helps users find lost items, report found items, and engage with the community to reunite belongings with their owners. Please follow these guidelines to ensure a smooth and respectful experience.'),
                      ],
                    ),
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Community Guidelines',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text('Be respectful and considerate in all interactions.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Avoid posting irrelevant or misleading information.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Do not spam, advertise unrelated content, or include malicious links or photos.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Keep comments constructive and relevant.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Report suspicious activity promptly.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Posting Guidelines',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text(
                          'Posts can be tagged as Lost, Found, General, or Resolved.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text('Provide a clear title and description.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Optional details include location (select a map point and radius), item color, size, brand, and up to 10 photos.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                      Text(
                          'Once resolved, posts can be marked accordingly by the creator or an admin.',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryBlack, fontSize: 14)),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Commenting & Interaction',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Users can comment and reply to posts, including one photo per comment. Posts, comments, and replies can be upvoted (liked) and bookmarked. If necessary, report inappropriate content via the menu button for admin review.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Browsing & Searching',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Browse posts sorted by recent activity. Use search to find posts by title, description, location, color, size, and brand. Filter posts by category, location radius, item details, and date range.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Profile Management',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Your profile includes a username, verified badge (if applicable), full name (initially from Google, but can be edited), bio, and contact details (email, phone, location) that can be set to public or private. All user posts and earned badges are displayed on the profile.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Recognition System',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Users earn badges based on milestones such as the number of posts, resolved cases, and community engagement through comments and upvotes.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Users receive notifications when their posts receive likes, comments, or replies, and when posts are marked as resolved.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bookmarks',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Users can bookmark posts for easy access later, with bookmarked posts listed under the Bookmarks section.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Settings',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Modify your profile details and privacy settings. Choose what information (email, phone, location) is public or private. Manage accessibility options and delete your account if needed.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Security',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'The app authenticates users through Google’s OAuth service, ensuring secure login. All data and images are securely stored in Google Firebase’s database and cloud storage, protecting your information.',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                ],
              )),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Thank you for being part of the '),
                  TextSpan(
                      text: 'InFound',
                      style: GoogleFonts.roboto(
                          color: AppStyles.primaryTeal,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: ' community!'),
                ],
              ),
              style: GoogleFonts.roboto(
                  color: AppStyles.primaryBlack, fontSize: 14),
            ),
          ),
          SizedBox(height: 16),
        ])),
        footer: firstTime
            ? Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButtonIcon(
                      onTap: () {
                        AppPopups.closeDialog();
                      },
                      height: 40,
                      buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                      withIcon: false,
                      withText: true,
                      text: 'I understand',
                    ),
                  ],
                ),
              )
            : null);
  }

  static void openAboutPopup() {
    openScrollablePopup(
        title: 'About InFound',
        titleAlignment: Alignment.center,
        maxWidth: 500,
        body: Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 80,
              width: double.infinity,
              alignment: Alignment.center,
              child: SvgPicture.asset(AppConstants.iAppIconFullColored)),
          Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(
                            text: 'InFound',
                            style: GoogleFonts.roboto(
                                color: AppStyles.primaryTeal,
                                fontWeight: FontWeight.w600)),
                        TextSpan(
                            text:
                                """, your trusted community platform for finding lost items and reuniting them with their rightful owners. Whether you've lost something valuable or found an item and want to return it, InFound makes the process simple and efficient."""),
                      ],
                    ),
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Why InFound?',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    """InFound is more than just an app—it's a community-driven solution that helps people recover lost belongings and return found items. With powerful search capabilities, easy posting, and secure interactions, InFound makes it easier than ever to connect and assist others.""",
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    """Join us and be part of the effort to make lost and found simple and efficient!""",
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Key Features',
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryTeal,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  BulletedList(
                    bulletColor: AppStyles.primaryBlack,
                    listItems: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Post Lost & Found Items: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Easily create posts for items you've lost or found. Provide details such as title, description, location, and optional attributes like color, size, and brand."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Categories for Organization: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Tag your post as Lost, Found, General, or mark it as Resolved once the item is returned."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Location-Based Search: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Use the interactive map to pinpoint where an item was lost or found and set a radius for better search accuracy."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Advanced Search & Filters: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Find items quickly by searching through titles, descriptions, locations, colors, sizes, and brands. Apply filters to refine results based on categories, dates, and other criteria."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Community Engagement: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Comment and reply on posts to help with inquiries, upvote (like) posts, comments, and replies to increase visibility, and bookmark posts for easy access later."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Recognition System: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Earn badges based on milestones and achievements, recognizing your contributions to the community."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Notifications: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Stay informed with real-time updates when someone interacts with your posts or comments."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Secure & Private: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Your data is safe with InFound, secured through Google's OAuth authentication and stored in Firebase with encryption and access controls."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Report & Review System: ',
                                style: GoogleFonts.roboto(
                                    color: AppStyles.primaryTeal,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text:
                                    """Keep the platform safe by reporting inappropriate posts, comments, or replies for admin review."""),
                          ],
                        ),
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                    listOrder: ListOrder.ordered,
                  ),
                ],
              )),
          SizedBox(height: 16),
          (AuthenticationRepository.instance.currentUserModel.value != null &&
                  !AuthenticationRepository
                      .instance.currentUserModel.value!.isVerified)
              ? Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Want to be an admin?',
                    style: GoogleFonts.roboto(
                        color: AppStyles.primaryBlack, fontSize: 14),
                  ),
                )
              : Container(),
          (AuthenticationRepository.instance.currentUserModel.value != null &&
                  !AuthenticationRepository
                      .instance.currentUserModel.value!.isVerified)
              ? Container(
                  alignment: Alignment.center,
                  child: TextButton(
                      onPressed: () async {
                        final isConnected =
                            await NetworkManager.instance.isConnected();
                        if (!isConnected) {
                          AppPopups.customToast(
                              message: 'No Internet Connection');
                          return;
                        }

                        try {
                          bool isSent = await DatabaseRepository.instance
                              .checkIfRequestExists(
                                  uid: AuthenticationRepository
                                      .instance.currentUserModel.value!.uid,
                                  type: "ADMIN");
                          if (isSent) {
                            AppPopups.warningSnackBar(
                              title: "InFound",
                              message:
                                  "You have already sent a request for admin access",
                            );
                            return;
                          } else {
                            UserRequestModel request = UserRequestModel(
                                requestId: uuid.v1(),
                                uid: AuthenticationRepository
                                    .instance.currentUserModel.value!.uid,
                                type: "ADMIN",
                                updatedAt: DateTime.now(),
                                createdAt: DateTime.now());
                            await DatabaseRepository.instance
                                .createUserRequest(request: request)
                                .then((_) {
                              AppPopups.customToast(
                                  message: "Request sent successfully");
                            });
                          }
                        } catch (e) {
                          AppPopups.customToast(
                              message:
                                  "An error occurred while requesting admin access. Please try again.");
                        }
                      },
                      child: Text('Request admin access',
                          style: GoogleFonts.roboto(
                              color: AppStyles.primaryTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600))))
              : Container(),
          SizedBox(height: 16),
        ])),
        footer: Container());
  }

  static void openReportDialog({
    required String type,
    required String postId,
    String? commentId,
    required String reporteeId,
    required String reporterId,
    required String targetId,
    required String title,
  }) {
    String? reason = null;
    openScrollablePopup(
        title: 'Report ${type.toLowerCase()}: "${title}"',
        maxWidth: 500,
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reason for report:',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                    color: AppStyles.primaryBlack, fontSize: 14),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                hint: Text('Choose a reason'),
                value: reason,
                items: AppConstants.lReportTypes.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  reason = newValue!;
                },
              ),
            ],
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButtonIcon(
                onTap: () async {
                  final isConnected =
                      await NetworkManager.instance.isConnected();
                  if (!isConnected) {
                    AppPopups.customToast(message: 'No Internet Connection');
                    return;
                  }
                  if (AuthenticationRepository
                          .instance.currentUserModel.value !=
                      null) {
                    if (reason != null) {
                      AppPopups.openLoadingDialog('Sending your report...',
                          AppConstants.aInFoundLoader);
                      try {
                        ReportModel report = ReportModel(
                            reportId: uuid.v1(),
                            type: type,
                            postId: postId,
                            status: 'ACTIVE',
                            commentId: commentId ?? '',
                            reporteeId: reporteeId,
                            reporterId: reporterId,
                            targetId: targetId,
                            reason: reason!,
                            updatedAt: DateTime.now(),
                            createdAt: DateTime.now());

                        await DatabaseRepository.instance
                            .createReport(report: report)
                            .then((_) {
                          AppPopups.closeDialog();
                          AppPopups.closeDialog();
                        });
                      } catch (e) {
                        AppPopups.closeDialog();
                        AppPopups.customToast(
                            message:
                                'An error occurred while sending your report. Please try again.');
                      }
                    }
                  }
                },
                height: 40,
                buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                withIcon: false,
                withText: true,
                text: 'Send report',
              ),
            ],
          ),
        ));
  }

  static void openPrivacyOptions() {
    RxBool showEmail = false.obs;
    RxBool showPhone = false.obs;
    RxBool showLocation = false.obs;
    RxBool showName = false.obs;

    showEmail.value =
        AuthenticationRepository.instance.currentUserModel.value!.isEmailPublic;
    showPhone.value =
        AuthenticationRepository.instance.currentUserModel.value!.isPhonePublic;
    showLocation.value = AuthenticationRepository
        .instance.currentUserModel.value!.isLocationPublic;
    showName.value =
        AuthenticationRepository.instance.currentUserModel.value!.isNamePublic;

    openScrollablePopup(
      title: 'Privacy Settings',
      maxWidth: 500,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what information to display on your profile:',
              style: GoogleFonts.poppins(
                  color: AppStyles.primaryTeal, fontSize: 18),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: showName.value,
                          activeColor: AppStyles.primaryTeal,
                          checkColor: AppStyles.pureWhite,
                          onChanged: (bool? value) {
                            showName.value = value!;
                          },
                        ),
                      ),
                      Text(
                        'Make name public',
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: showEmail.value,
                          activeColor: AppStyles.primaryTeal,
                          checkColor: AppStyles.pureWhite,
                          onChanged: (bool? value) {
                            showEmail.value = value!;
                          },
                        ),
                      ),
                      Text(
                        'Make email address public',
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: showPhone.value,
                          activeColor: AppStyles.primaryTeal,
                          checkColor: AppStyles.pureWhite,
                          onChanged: (bool? value) {
                            showPhone.value = value!;
                          },
                        ),
                      ),
                      Text(
                        'Make phone number public',
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: showLocation.value,
                          activeColor: AppStyles.primaryTeal,
                          checkColor: AppStyles.pureWhite,
                          onChanged: (bool? value) {
                            showLocation.value = value!;
                          },
                        ),
                      ),
                      Text(
                        'Make location public',
                        style: GoogleFonts.roboto(
                            color: AppStyles.primaryBlack, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            SettingsOptionContainer(
              icon: Icons.perm_device_information_rounded,
              title: 'Review privacy policy',
              onClick: () {
                AppPopups.openPrivacyStatement();
              },
            )
          ],
        ),
      ),
      footer: Container(
        height: 50,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialButtonIcon(
                height: 40,
                buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                withIcon: false,
                withText: true,
                text: 'Update',
                onTap: () async {
                  final isConnected =
                      await NetworkManager.instance.isConnected();
                  if (!isConnected) {
                    AppPopups.customToast(message: 'No Internet Connection');
                    return;
                  }
                  AppPopups.openLoadingDialog('Updating privacy settings...',
                      AppConstants.aInFoundLoader);

                  try {
                    UserModel updatedUser = AuthenticationRepository
                        .instance.currentUserModel.value!
                        .copyWith(
                      isEmailPublic: showEmail.value,
                      isPhonePublic: showPhone.value,
                      isLocationPublic: showLocation.value,
                      isNamePublic: showName.value,
                    );
                    await DatabaseRepository.instance
                        .updateUser(user: updatedUser)
                        .then((_) {
                      AuthenticationRepository.instance.currentUserModel.value =
                          updatedUser;
                      AppPopups.closeDialog();
                      AppPopups.closeDialog();
                    });
                  } catch (e) {
                    AppPopups.closeDialog();
                    AppPopups.customToast(
                        message:
                            'An error occurred while updating privacy settings. Please try again.');
                  }
                }),
          ],
        ),
      ),
    );
  }

  static void openBadgeView(
      {required BuildContext context,
      required BadgeModel badge,
      bool adminView = false,
      String? userId,
      Function(BadgeModel)? onEdit,
      Function(BadgeModel)? onDelete,
      Function(BadgeModel)? onRevoke}) {
    RxString badgeTitleObs = badge.badgeTitle.obs;
    RxString badgeDescriptionObs = badge.badgeDescription.obs;
    RxString badgeConditionObs = badge.badgeCondition.obs;
    RxString badgeIconObs = badge.badgeIconUrl.obs;
    RxString tierObs = badge.tier.obs;
    Rx<DateTime> updatedAtObs = badge.updatedAt.obs;
    RxList<String> ownersObs = badge.badgeOwners.obs;

    openScrollablePopup(
      maxWidth: 400,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () => Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    AppStyles()
                        .lightBoxShadow(AppStyles.primaryBlack.withAlpha(150))
                  ],
                  color: tierObs.value == 'BRONZE'
                      ? AppStyles.primaryBronze
                      : tierObs.value == 'SILVER'
                          ? AppStyles.primarySilver
                          : tierObs.value == 'GOLD'
                              ? AppStyles.primaryGold
                              : tierObs.value == 'PLATINUM'
                                  ? AppStyles.primaryPlatinum
                                  : tierObs.value == 'DIAMOND'
                                      ? AppStyles.primaryDiamond
                                      : AppStyles.primaryTeal,
                ),
                alignment: Alignment.center,
                child: Container(
                  height: 115,
                  width: 115,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: AppStyles.pureWhite),
                  alignment: Alignment.center,
                  child: badgeIconObs.value == ''
                      ? Container(
                          height: 115,
                          width: 115,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 80,
                            color: tierObs.value == 'BRONZE'
                                ? AppStyles.primaryBronze
                                : tierObs.value == 'SILVER'
                                    ? AppStyles.primarySilver
                                    : tierObs.value == 'GOLD'
                                        ? AppStyles.primaryGold
                                        : tierObs.value == 'PLATINUM'
                                            ? AppStyles.primaryPlatinum
                                            : tierObs.value == 'DIAMOND'
                                                ? AppStyles.primaryDiamond
                                                : AppStyles.primaryTeal,
                          ),
                        )
                      : Container(
                          height: 115,
                          width: 115,
                          child: AppRoundedImage(
                            imageType: ImageType.network,
                            image: badgeIconObs.value,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => Text(
                '${badgeTitleObs.value} (${tierObs.value.substring(0, 1).toUpperCase()}${tierObs.value.substring(1).toLowerCase()})',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: AppStyles.primaryBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Obx(
              () => Text(
                badgeDescriptionObs.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    color: AppStyles.primaryBlack, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Condition:',
              style: GoogleFonts.roboto(
                  color: AppStyles.primaryBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            Obx(
              () => Text(
                badgeConditionObs.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    color: AppStyles.primaryBlack, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      footer: (AuthenticationRepository
                  .instance.currentUserModel.value?.isAdmin ??
              false)
          ? Container(
              height: 50,
              width: double.infinity,
              child: adminView
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButtonIcon(
                          onTap: () async {
                            openBadgeGrantRevoke(badge: badge);
                          },
                          height: 40,
                          buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                          withIcon: false,
                          withText: true,
                          text: 'Grant/Revoke',
                        ),
                        MaterialButtonIcon(
                          onTap: () async {
                            openBadgeEditor(
                                isEditing: true,
                                badge: BadgeModel(
                                    badgeId: badge.badgeId,
                                    badgeTitle: badgeTitleObs.value,
                                    badgeDescription: badgeDescriptionObs.value,
                                    badgeIconUrl: badgeIconObs.value,
                                    badgeCondition: badgeConditionObs.value,
                                    tier: tierObs.value,
                                    badgeOwners: ownersObs,
                                    updatedAt: updatedAtObs.value,
                                    createdAt: badge.createdAt),
                                onEdit: (String badgeId,
                                    String badgeTitle,
                                    String badgeDescription,
                                    String badgeCondition,
                                    String badgeIcon,
                                    String tier) {
                                  BadgeModel updatedBadge = badge.copyWith(
                                      badgeTitle: badgeTitle,
                                      badgeDescription: badgeDescription,
                                      badgeCondition: badgeCondition,
                                      badgeIconUrl: badgeIcon,
                                      tier: tier,
                                      updatedAt: DateTime.now());
                                  badgeTitleObs.value = badgeTitle;
                                  badgeDescriptionObs.value = badgeDescription;
                                  badgeConditionObs.value = badgeCondition;
                                  badgeIconObs.value = badgeIcon;
                                  tierObs.value = tier;
                                  updatedAtObs.value = DateTime.now();
                                  if (onEdit != null) onEdit(updatedBadge);
                                });
                          },
                          height: 40,
                          buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                          withIcon: false,
                          withText: true,
                          text: 'Edit',
                        ),
                        MaterialButtonIcon(
                          onTap: () async {
                            AppPopups.confirmDialog(
                                title: 'Delete Badge',
                                content:
                                    'Are you sure you want to delete this badge? This action cannot be undone.',
                                accentColor: AppStyles.primaryRed,
                                confirmText: 'Delete',
                                onConfirm: () async {
                                  final isConnected = await NetworkManager
                                      .instance
                                      .isConnected();
                                  if (!isConnected) {
                                    AppPopups.customToast(
                                        message: 'No Internet Connection');
                                    return;
                                  }
                                  try {
                                    await DatabaseRepository.instance
                                        .deleteBadgeById(badgeId: badge.badgeId)
                                        .then((_) {
                                      AppPopups.closeDialog();
                                      AppPopups.closeDialog();
                                      if (onDelete != null) onDelete(badge);
                                      AppPopups.customToast(
                                          message:
                                              'Badge deleted successfully');
                                    });
                                  } catch (e) {
                                    AppPopups.customToast(
                                        message:
                                            'An error occurred while deleting badge. Please try again.');
                                  }
                                });
                          },
                          height: 40,
                          buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                          buttonColor: AppStyles.primaryRed,
                          withIcon: false,
                          withText: true,
                          text: 'Delete',
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButtonIcon(
                          onTap: () async {
                            try {
                              await DatabaseRepository.instance.revokeBadge(
                                  badgeId: badge.badgeId, userId: userId ?? '');
                              if (onRevoke != null) onRevoke(badge);
                              AppPopups.closeDialog();
                              AppPopups.customToast(
                                  message: 'Badge revoked successfully');
                            } catch (e) {
                              AppPopups.customToast(
                                  message:
                                      'An error occurred while revoking badge. Please try again.');
                            }
                          },
                          height: 40,
                          buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                          buttonColor: AppStyles.primaryRed,
                          withIcon: false,
                          withText: true,
                          text: 'Revoke',
                        ),
                      ],
                    ),
            )
          : Container(),
    );
  }

  static void openBadgeGrantRevoke({required BadgeModel badge}) {
    showDialog(
        context: Get.overlayContext!,
        barrierDismissible: false,
        builder: (_) {
          return PopScope(
            canPop: false, // Disable popping with the back button
            child: Container(
              margin: EdgeInsets.all(30),
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: Stack(
                      children: [
                        IntrinsicHeight(
                          child: GrantRevokeWidget(
                            badge: badge,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                color: AppStyles.primaryTeal,
                                borderRadius: BorderRadius.circular(16)),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppStyles.pureWhite,
                                size: 16,
                              ),
                              onPressed: () {
                                AppPopups.closeDialog();
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          );
        });
  }

  static void openBadgeEditor(
      {required bool isEditing,
      BadgeModel? badge,
      Function(String, String, String, String, String, String)? onEdit,
      Function(BadgeModel)? onCreate}) {
    TextEditingController badgeTitleController =
        TextEditingController(text: isEditing ? (badge?.badgeTitle ?? "") : '');
    TextEditingController badgeDescriptionController = TextEditingController(
        text: isEditing ? (badge?.badgeDescription ?? "") : '');
    TextEditingController badgeConditionController = TextEditingController(
        text: isEditing ? (badge?.badgeCondition ?? "") : '');
    RxString badgeTier = 'BRONZE'.obs;
    RxString badgeIcon = ''.obs;
    badgeIcon.value = isEditing ? badge!.badgeIconUrl : '';

    if (isEditing) {
      badgeIcon.value = badge!.badgeIconUrl;
      badgeTier.value = badge.tier;
    }

    Rx<Uint8List?> tempImage = Rx<Uint8List?>(null);
    Rx<XFile?> tempXFile = Rx<XFile?>(null);
    RxBool editIconVisible = false.obs;

    Future<void> getImage() async {
      final ImagePicker _picker = ImagePicker();
      XFile? temp = await _picker.pickImage(source: ImageSource.gallery);
      if (temp != null) {
        badgeIcon.value = '';
        tempXFile.value = temp;
        tempImage.value = await temp.readAsBytes();
      }
    }

    Future saveEdits() async {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        AppPopups.customToast(message: 'No Internet Connection');
        return;
      }

      if (badgeTitleController.text == '') {
        AppPopups.errorSnackBar(
            title: 'Invalid badge title',
            message: 'Badge title cannot be empty.');
        return;
      }

      if (badgeDescriptionController.text == '') {
        AppPopups.errorSnackBar(
            title: 'Invalid badge description',
            message: 'Badge description cannot be empty.');
        return;
      }

      if (badgeConditionController.text == '') {
        AppPopups.errorSnackBar(
            title: 'Invalid badge condition',
            message: 'Badge condition cannot be empty.');
        return;
      }

      AppPopups.openLoadingDialog(
          isEditing ? 'Saving changes...' : 'Creating badge...',
          AppConstants.aInFoundLoader);
      String badgeId = isEditing ? badge!.badgeId : uuid.v1();
      try {
        String imageURL = '';
        if (tempXFile.value != null) {
          final storageRepository = Get.put(StorageRepository());
          var imageBytes = await tempXFile.value!.readAsBytes();
          imageURL = await storageRepository.uploadImage(
              imageName:
                  "badge-${badgeId}.${getFileExtension(tempXFile.value!)}",
              bytes: imageBytes,
              path: 'badges/${badgeId}/',
              contentType: tempXFile.value!.mimeType ?? '');
        }
        if (imageURL == '' && tempXFile.value != null) {
          AppPopups.closeDialog();
          AppPopups.errorSnackBar(
              title: 'Image upload failed',
              message: 'Failed to upload image. Please try again.');
          return;
        } else {
          String newBadgeIcon = '';
          if (badgeIcon.value != '') {
            newBadgeIcon = badgeIcon.value;
          } else {
            newBadgeIcon = imageURL;
          }

          BadgeModel newBadge = isEditing
              ? badge!.copyWith(
                  badgeTitle: badgeTitleController.text,
                  badgeDescription: badgeDescriptionController.text,
                  badgeIconUrl: newBadgeIcon,
                  badgeCondition: badgeConditionController.text,
                  tier: badgeTier.value,
                  updatedAt: DateTime.now(),
                )
              : BadgeModel(
                  badgeId: badgeId,
                  badgeTitle: badgeTitleController.text,
                  badgeDescription: badgeDescriptionController.text,
                  badgeIconUrl: newBadgeIcon,
                  badgeCondition: badgeConditionController.text,
                  tier: badgeTier.value,
                  badgeOwners: [],
                  updatedAt: DateTime.now(),
                  createdAt: DateTime.now());

          if (isEditing) {
            await DatabaseRepository.instance
                .updateBadge(badge: newBadge)
                .then((_) {
              AppPopups.closeDialog();
              AppPopups.closeDialog();
              if (onEdit != null)
                onEdit(
                    badgeId,
                    badgeTitleController.text,
                    badgeDescriptionController.text,
                    badgeConditionController.text,
                    newBadgeIcon,
                    badgeTier.value);
            });
          } else {
            await DatabaseRepository.instance
                .createBadge(badge: newBadge)
                .then((_) {
              AppPopups.closeDialog();
              AppPopups.closeDialog();
              if (onCreate != null) onCreate(newBadge);
            });
          }
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(
            title: 'Error',
            message: 'An error occurred while saving badge. Please try again.');
      }
    }

    openScrollablePopup(
        title: isEditing ? 'Edit Badge' : 'Create Badge',
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 200,
              alignment: Alignment.topCenter,
              //profile
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          AppStyles().lightBoxShadow(
                              AppStyles.primaryBlack.withAlpha(150))
                        ],
                        color: badgeTier.value == 'BRONZE'
                            ? AppStyles.primaryBronze
                            : badgeTier.value == 'SILVER'
                                ? AppStyles.primarySilver
                                : badgeTier.value == 'GOLD'
                                    ? AppStyles.primaryGold
                                    : badgeTier.value == 'PLATINUM'
                                        ? AppStyles.primaryPlatinum
                                        : badgeTier.value == 'DIAMOND'
                                            ? AppStyles.primaryDiamond
                                            : AppStyles.primaryTeal,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 115,
                        width: 115,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: AppStyles.pureWhite),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Obx(
                              () => badgeIcon.value == '' &&
                                      tempImage.value == null
                                  ? Container(
                                      height: 115,
                                      width: 115,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 80,
                                        color: badgeTier.value == 'BRONZE'
                                            ? AppStyles.primaryBronze
                                            : badgeTier.value == 'SILVER'
                                                ? AppStyles.primarySilver
                                                : badgeTier.value == 'GOLD'
                                                    ? AppStyles.primaryGold
                                                    : badgeTier.value ==
                                                            'PLATINUM'
                                                        ? AppStyles
                                                            .primaryPlatinum
                                                        : badgeTier.value ==
                                                                'DIAMOND'
                                                            ? AppStyles
                                                                .primaryDiamond
                                                            : AppStyles
                                                                .primaryTeal,
                                      ),
                                    )
                                  : Container(
                                      height: 115,
                                      width: 115,
                                      child: AppRoundedImage(
                                        imageType: badgeIcon.value != ''
                                            ? ImageType.network
                                            : ImageType.memory,
                                        image: badgeIcon.value != ''
                                            ? badgeIcon.value
                                            : null,
                                        memoryImage: badgeIcon.value == '' &&
                                                tempImage.value != null
                                            ? tempImage.value!
                                            : null,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Material(
                              type: MaterialType.transparency,
                              borderRadius: BorderRadius.circular(35),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(35),
                                onTap: () {
                                  getImage();
                                },
                                onHover: (hovering) {
                                  editIconVisible.value = hovering;
                                },
                                hoverColor: AppStyles.mediumGray.withAlpha(100),
                                splashColor: AppStyles.lightGrey.withAlpha(50),
                                highlightColor:
                                    AppStyles.lightGrey.withAlpha(50),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Container(
                                    height: 115,
                                    width: 115,
                                    child: Center(
                                        child: Obx(
                                      () => Icon(
                                        Icons.edit_rounded,
                                        color: editIconVisible.value
                                            ? AppStyles.pureWhite
                                                .withOpacity(0.9)
                                            : Colors.transparent,
                                        size: 24,
                                      ),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => (badgeIcon.value != '' || tempImage.value != null)
                        ? TextButton(
                            onPressed: () {
                              badgeIcon.value = '';
                              tempImage.value = null;
                            },
                            child: Text('Remove',
                                style: GoogleFonts.poppins(
                                    color: AppStyles.primaryRed,
                                    fontWeight: FontWeight.w600)))
                        : Container(),
                  ),
                  SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(maxWidth: 100),
                    child: Obx(() {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: (AppConstants.lBadgeTypes.keys.toList())
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppConstants.lBadgeTypes[value],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppStyles.pureWhite,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            badgeTier.value = value!;
                          },
                          selectedItemBuilder: (context) =>
                              (AppConstants.lBadgeTypes.keys.toList())
                                  .map((String value) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppConstants.lBadgeTypes[value],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                value,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppStyles.pureWhite,
                                ),
                              ),
                            );
                          }).toList(),
                          elevation: 8,
                          iconSize: 14,
                          value: badgeTier.value,
                          padding: EdgeInsets.all(0),
                          isDense: true,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: AppStyles.pureWhite,
                          alignment: Alignment.center,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge Title:',
                        style: GoogleFonts.poppins(
                            color: AppStyles.primaryTeal, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: badgeTitleController,
                        decoration: InputDecoration(
                          hintText: 'Badge title',
                          hintStyle:
                              GoogleFonts.roboto(color: AppStyles.lightGrey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Badge Description:',
                        style: GoogleFonts.poppins(
                            color: AppStyles.primaryTeal, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      IntrinsicHeight(
                        child: TextField(
                          maxLines: null,
                          expands: true,
                          controller: badgeDescriptionController,
                          decoration: InputDecoration(
                            hintText: 'Badge description',
                            hintStyle:
                                GoogleFonts.roboto(color: AppStyles.lightGrey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Badge Condition:',
                        style: GoogleFonts.poppins(
                            color: AppStyles.primaryTeal, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      IntrinsicHeight(
                        child: TextField(
                          maxLines: null,
                          expands: true,
                          controller: badgeConditionController,
                          decoration: InputDecoration(
                            hintText:
                                'Badge condition (e.g. Awarded for 10 resolved cases)',
                            hintStyle:
                                GoogleFonts.roboto(color: AppStyles.lightGrey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButtonIcon(
                onTap: () async {
                  await saveEdits();
                },
                height: 40,
                buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                withIcon: false,
                withText: true,
                text: isEditing ? 'Update' : 'Create badge',
              ),
            ],
          ),
        ));
  }

  static void openProfileEditor({required UserModel user}) {
    Rx<bool?> nameError = Rx<bool?>(null);
    TextEditingController nameController =
        TextEditingController(text: user.name != '' ? user.name : '');
    TextEditingController bioController =
        TextEditingController(text: user.bio != '' ? user.bio : '');
    RxString location = ''.obs;
    location.value = user.location;
    TextEditingController phoneController =
        TextEditingController(text: user.phone != '' ? user.phone : '');
    TextEditingController userNameController =
        TextEditingController(text: user.userName);
    RxString profileUrl = ''.obs;
    profileUrl.value = user.profileURL;
    Rx<Uint8List?> tempImage = Rx<Uint8List?>(null);
    Rx<XFile?> tempXFile = Rx<XFile?>(null);
    RxBool editIconVisible = false.obs;

    Future<void> getImage() async {
      final ImagePicker _picker = ImagePicker();
      XFile? temp = await _picker.pickImage(source: ImageSource.gallery);
      if (temp != null) {
        profileUrl.value = '';
        tempXFile.value = temp;
        tempImage.value = await temp.readAsBytes();
      }
    }

    Future saveEdits() async {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        AppPopups.customToast(message: 'No Internet Connection');
        return;
      }

      if (userNameController.text != user.userName) {
        nameError.value = !(await DatabaseRepository.instance
            .checkUsernameAvailability(username: userNameController.text));
        if (nameError.value!) {
          return;
        }
      }

      if (phoneController.text != '') {
        if (phoneController.text.length != 10 ||
            !phoneController.text.isNumericOnly) {
          AppPopups.errorSnackBar(
              title: 'Invalid phone number',
              message: 'Please enter a valid 10-digit phone number.');
          return;
        }
      }

      AppPopups.openLoadingDialog(
          'Saving changes...', AppConstants.aInFoundLoader);
      try {
        String imageURL = '';
        if (tempXFile.value != null) {
          final storageRepository = Get.put(StorageRepository());
          var imageBytes = await tempXFile.value!.readAsBytes();
          imageURL = await storageRepository.uploadImage(
              imageName:
                  "profile-${user.uid}.${getFileExtension(tempXFile.value!)}",
              bytes: imageBytes,
              path: 'users/${user.uid}/',
              contentType: tempXFile.value!.mimeType ?? '');
        }
        if (imageURL == '' && tempXFile.value != null) {
          AppPopups.closeDialog();
          AppPopups.errorSnackBar(
              title: 'Image upload failed',
              message: 'Failed to upload image. Please try again.');
          return;
        } else {
          String newProfile = '';
          if (profileUrl.value != '') {
            newProfile = profileUrl.value;
          } else {
            newProfile = imageURL;
          }

          UserModel newUser = user.copyWith(
              name: nameController.text,
              bio: bioController.text,
              location: location.value,
              phone: phoneController.text,
              userName: userNameController.text,
              profileURL: newProfile);

          await DatabaseRepository.instance.updateUser(user: newUser).then((_) {
            if (AuthenticationRepository.instance.currentUserModel.value!.uid ==
                newUser.uid) {
              AuthenticationRepository.instance.currentUserModel.value =
                  newUser;
            }
            Get.offNamed('/profile/${newUser.userName}',
                preventDuplicates: false);
          });
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(
            title: 'Error',
            message:
                'An error occurred while saving profile. Please try again.');
      }
    }

    openScrollablePopup(
        title: 'Edit profile',
        body: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                alignment: Alignment.topCenter,
                //profile
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 145,
                      width: 145,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        boxShadow: [
                          AppStyles().lightBoxShadow(
                              AppStyles.primaryBlack.withAlpha(150))
                        ],
                        color: AppStyles.pureWhite,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Obx(
                              () => profileUrl.value == '' &&
                                      tempImage.value == null
                                  ? Container(
                                      height: 120,
                                      width: 120,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.account_circle_outlined,
                                        size: 120,
                                        color: AppStyles.primaryTealLighter,
                                      ),
                                    )
                                  : Container(
                                      height: 120,
                                      width: 120,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: AppRoundedImage(
                                        imageType: profileUrl.value != ''
                                            ? ImageType.network
                                            : ImageType.memory,
                                        image: profileUrl.value != ''
                                            ? profileUrl.value
                                            : null,
                                        memoryImage: profileUrl.value == '' &&
                                                tempImage.value != null
                                            ? tempImage.value!
                                            : null,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Material(
                              type: MaterialType.transparency,
                              borderRadius: BorderRadius.circular(100),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  getImage();
                                },
                                onHover: (hovering) {
                                  editIconVisible.value = hovering;
                                },
                                hoverColor: AppStyles.mediumGray.withAlpha(100),
                                splashColor: AppStyles.lightGrey.withAlpha(50),
                                highlightColor:
                                    AppStyles.lightGrey.withAlpha(50),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Container(
                                    height: 120,
                                    width: 120,
                                    child: Center(
                                        child: Obx(
                                      () => Icon(
                                        Icons.edit_rounded,
                                        color: editIconVisible.value
                                            ? AppStyles.pureWhite
                                                .withOpacity(0.9)
                                            : Colors.transparent,
                                        size: 24,
                                      ),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(
                      () => (profileUrl.value != '' || tempImage.value != null)
                          ? TextButton(
                              onPressed: () {
                                profileUrl.value = '';
                                tempImage.value = null;
                              },
                              child: Text('Remove',
                                  style: GoogleFonts.poppins(
                                      color: AppStyles.primaryRed,
                                      fontWeight: FontWeight.w600)))
                          : Container(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      nameError.value = null;
                                    },
                                    inputFormatters: [
                                      AlphanumericFormatter(),
                                      LengthLimitingTextInputFormatter(30)
                                    ],
                                    controller: userNameController,
                                    decoration: InputDecoration.collapsed(
                                        hintText: 'username001',
                                        hintStyle: GoogleFonts.poppins(
                                            color: AppStyles.lightGrey)),
                                    style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        color: AppStyles.primaryBlack,
                                        fontWeight: FontWeight.w600,
                                        height: 1),
                                  ),
                                ),
                                MaterialButtonIcon(
                                  onTap: () async {
                                    final isConnected = await NetworkManager
                                        .instance
                                        .isConnected();
                                    if (!isConnected) {
                                      AppPopups.customToast(
                                          message: 'No Internet Connection');
                                      return;
                                    }
                                    if (userNameController.text !=
                                            user.userName &&
                                        userNameController.text != '') {
                                      nameError.value =
                                          !(await DatabaseRepository.instance
                                              .checkUsernameAvailability(
                                                  username:
                                                      userNameController.text));
                                    } else {
                                      nameError.value = false;
                                    }
                                  },
                                  height: 35,
                                  fontSize: 14,
                                  buttonPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  withIcon: false,
                                  withText: true,
                                  text: 'CHECK',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Obx(
                          () => nameError.value != null
                              ? nameError.value!
                                  ? Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      child: Text('Username is already taken.',
                                          style: GoogleFonts.roboto(
                                              color: AppStyles.primaryRed,
                                              fontSize: 12)),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      child: Text('You can use this username.',
                                          style: GoogleFonts.roboto(
                                              color: AppStyles.primaryTeal,
                                              fontSize: 12)),
                                    )
                              : Container(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 24,
                          width: double.infinity,
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: nameController,
                            maxLines: 1,
                            decoration: InputDecoration.collapsed(
                                hintText: 'Full name',
                                hintStyle: GoogleFonts.poppins(
                                    color: AppStyles.lightGrey)),
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppStyles.primaryBlack,
                                height: 1.25),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        IntrinsicHeight(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 24),
                            width: double.infinity,
                            child: TextField(
                              controller: bioController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(200)
                              ],
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Bio',
                                  hintStyle: GoogleFonts.poppins(
                                      color: AppStyles.lightGrey)),
                              style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: AppStyles.primaryBlack,
                                  height: 1.25),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: AppStyles.lightGrey,
                                      size: 14,
                                    )),
                                Text(
                                  "Email: ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                      fontSize: 14, color: AppStyles.lightGrey),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    user.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: AppStyles.primaryTeal,
                                        height: 1.25),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 24,
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.phone_outlined,
                                    color: AppStyles.lightGrey,
                                    size: 14,
                                  )),
                              Text(
                                "Phone No.: ",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14, color: AppStyles.lightGrey),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "+63",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: AppStyles.primaryBlack),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: phoneController,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  maxLines: 1,
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'XXX XXX XXXX',
                                      hintStyle: GoogleFonts.poppins(
                                          color: AppStyles.lightGrey)),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppStyles.primaryTeal,
                                      height: 1.25),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: AppStyles.lightGrey,
                                      size: 14,
                                    )),
                                Text(
                                  "Location: ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                      fontSize: 14, color: AppStyles.lightGrey),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        openMapPicker(
                                            currentLatitude: null,
                                            currentLongitude: null,
                                            onSubmit: (addr, coords) {
                                              location.value = addr;
                                            });
                                      },
                                      child: Obx(
                                        () => Text(
                                          location.value == ''
                                              ? "SET LOCATION"
                                              : location.value,
                                          style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: AppStyles.primaryTeal,
                                              height: 1.25),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => location != ''
                                      ? TextButton(
                                          onPressed: () {
                                            location.value = '';
                                          },
                                          child: Text('Remove',
                                              style: GoogleFonts.poppins(
                                                  color: AppStyles.primaryRed,
                                                  fontWeight: FontWeight.w600)))
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButtonIcon(
                onTap: () async {
                  await saveEdits();
                },
                height: 40,
                buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                withIcon: false,
                withText: true,
                text: 'Update',
              ),
            ],
          ),
        ));
  }

  static void openMapPicker(
      {double? currentLatitude,
      double? currentLongitude,
      double? currentRadius,
      required Function(String, String) onSubmit}) async {
    double? useLatitude;
    double? useLongitude;
    if (currentLatitude == null || currentLongitude == null) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        customToast(message: 'Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await confirmDialog(
              title: 'Enable Location',
              content:
                  'Location permissions are off. Please enable location permissions to continue.',
              confirmText: 'Request',
              cancelText: 'Cancel',
              onConfirm: () async {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  closeDialog();
                  errorSnackBar(
                      title: 'Request denied',
                      message:
                          'Location permissions are denied. Using default location.');
                } else if (permission == LocationPermission.deniedForever) {
                  errorSnackBar(
                      title: 'Location permissions denied',
                      message:
                          'Location permissions are permanently denied, using default location.');
                }
              },
              onCancel: () {
                closeDialog();
                errorSnackBar(
                    title: 'Request denied',
                    message:
                        'Location permissions are denied. Using default location.');
              });
        } else if (permission == LocationPermission.deniedForever) {
          errorSnackBar(
              title: 'Location permissions denied',
              message:
                  'Location permissions are permanently denied, using default location.');
        }
      } else if (permission == LocationPermission.deniedForever) {
        errorSnackBar(
            title: 'Location permissions denied',
            message:
                'Location permissions are permanently denied, using default location.');
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        late LocationSettings locationSettings;
        if (defaultTargetPlatform == TargetPlatform.android) {
          locationSettings = AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
            forceLocationManager: true,
            intervalDuration: const Duration(seconds: 10),
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.fitness,
            distanceFilter: 100,
            pauseLocationUpdatesAutomatically: true,
          );
        } else if (kIsWeb) {
          locationSettings = WebSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
            maximumAge: Duration(minutes: 5),
          );
        } else {
          locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          );
        }
        Position currentLoc = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings);
        useLatitude = currentLoc.latitude;
        useLongitude = currentLoc.longitude;
      }
    } else {
      useLatitude = currentLatitude;
      useLongitude = currentLongitude;
    }

    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: GoogleMapsWidget(
            onSubmit: (location, coord) {
              onSubmit(location, coord);
            },
            initialRadius: currentRadius ?? 50,
            initialLatLng: LatLng(useLatitude ?? 15.133187083840205,
                useLongitude ?? 120.58927892848014)),
      ),
    );
  }

  static void openMapViewer(
      {required double? currentLatitude,
      required double? currentLongitude,
      required double? currentRadius,
      required Function(String, String) onSubmit}) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: GoogleMapsWidget(
            onSubmit: (location, coord) {},
            initialRadius: currentRadius ?? 50,
            clickable: false,
            initialLatLng: LatLng(currentLatitude ?? 15.133187083840205,
                currentLongitude ?? 120.58927892848014)),
      ),
    );
  }

  static void openImageViewer(List<String> images, int initial) {
    RxInt currentIndex = initial.obs;
    PageController controller = PageController(initialPage: currentIndex.value);
    PhotoViewController photoViewController = PhotoViewController();
    RxDouble defaultZoom = (photoViewController.initial.scale ?? 0).obs;
    RxDouble currentZoom =
        (photoViewController.initial.scale ?? defaultZoom.value).obs;
    bool defaultSet = false;
    printDebug("Default: ${defaultZoom.value}");
    printDebug("Current: ${currentZoom.value}");
    showDialog(
      context:
          Get.overlayContext!, // Use Get.overlayContext for overlay dialogs
      barrierDismissible:
          false, // The dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Container(
          margin: EdgeInsets.all(30),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          height: double.infinity,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: PhotoViewGallery.builder(
                    itemCount: images.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:
                            CachedNetworkImageProvider(images[index]),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 4,
                        heroAttributes:
                            PhotoViewHeroAttributes(tag: images[index]),
                        disableGestures: false,
                        controller: photoViewController,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Icon(Icons.error_outline_rounded,
                                  color: AppStyles.mediumGray),
                            ),
                          );
                        },
                      );
                    },
                    loadingBuilder: (context, event) {
                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            AppShimmerEffect(
                                width: double.infinity,
                                height: double.infinity),
                            Center(
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  value: event == null
                                      ? 0
                                      : event.cumulativeBytesLoaded /
                                          event.expectedTotalBytes!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    pageController: controller,
                    onPageChanged: (index) {
                      currentIndex.value = index;
                      currentZoom.value =
                          (photoViewController.initial.scale ?? 0);
                      defaultZoom.value =
                          (photoViewController.initial.scale ?? 0);
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppStyles.primaryBlack.withAlpha(150),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  '${currentIndex.value + 1} of ${images.length}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppStyles.pureWhite,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                  width: 100,
                                  height: 50,
                                  child: Obx(
                                    () => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppStyles.primaryBlack
                                                  .withAlpha(150),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.zoom_in,
                                                  color: (currentZoom.value < 5)
                                                      ? AppStyles.pureWhite
                                                      : AppStyles.mediumGray),
                                              onPressed: (currentZoom.value < 5)
                                                  ? () {
                                                      if (photoViewController
                                                                  .scale !=
                                                              null &&
                                                          !defaultSet) {
                                                        defaultZoom.value =
                                                            photoViewController
                                                                .scale!;
                                                        defaultSet = true;
                                                      }
                                                      var newScale = min(
                                                          max(
                                                              (photoViewController
                                                                          .scale ??
                                                                      defaultZoom
                                                                          .value) *
                                                                  1.25,
                                                              defaultZoom
                                                                  .value),
                                                          5.0);
                                                      photoViewController
                                                          .updateMultiple(
                                                              scale: newScale);
                                                      currentZoom.value =
                                                          newScale;

                                                      printDebug(
                                                          "Default: ${defaultZoom.value}");
                                                      printDebug(
                                                          "Current: ${currentZoom.value}");
                                                    }
                                                  : null,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppStyles.primaryBlack
                                                  .withAlpha(150),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.zoom_out,
                                                  color: (currentZoom.value >
                                                          defaultZoom.value)
                                                      ? AppStyles.pureWhite
                                                      : AppStyles.mediumGray),
                                              onPressed: (currentZoom.value >=
                                                      defaultZoom.value)
                                                  ? () {
                                                      if (photoViewController
                                                                  .scale !=
                                                              null &&
                                                          !defaultSet) {
                                                        defaultZoom.value =
                                                            photoViewController
                                                                .scale!;
                                                        defaultSet = true;
                                                      }
                                                      var newScale = min(
                                                          max(
                                                              (photoViewController
                                                                          .scale ??
                                                                      defaultZoom
                                                                          .value) *
                                                                  0.75,
                                                              defaultZoom
                                                                  .value),
                                                          5.0);
                                                      photoViewController
                                                          .updateMultiple(
                                                              scale: newScale);
                                                      currentZoom.value =
                                                          newScale;
                                                      currentZoom.value =
                                                          newScale;

                                                      printDebug(
                                                          "Default: ${defaultZoom.value}");
                                                      printDebug(
                                                          "Current: ${currentZoom.value}");
                                                    }
                                                  : null,
                                            ),
                                          ),
                                        ]),
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currentIndex.value > 0
                            ? Flexible(
                                child: Container(
                                  margin: EdgeInsets.only(left: 20),
                                  height: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryBlack
                                            .withAlpha(150),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: AppStyles.pureWhite),
                                        onPressed: () {
                                          if (currentIndex > 0) {
                                            currentIndex--;
                                            controller.animateToPage(
                                                currentIndex.value,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: double.infinity,
                              ),
                        currentIndex.value < images.length - 1
                            ? Flexible(
                                child: Container(
                                  height: double.infinity,
                                  margin: EdgeInsets.only(right: 20),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryBlack
                                            .withAlpha(150),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: AppStyles.pureWhite),
                                        onPressed: () {
                                          if (currentIndex <
                                              images.length - 1) {
                                            currentIndex++;
                                            controller.animateToPage(
                                                currentIndex.value,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.easeInOut);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: double.infinity,
                              ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Container(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppStyles.primaryBlack.withAlpha(150),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppStyles.pureWhite),
                          onPressed: () {
                            closeDialog();
                            controller.dispose();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static openDeleteAccountDialog({
    required BuildContext context,
  }) {
    TextEditingController emailInput = TextEditingController();
    TextEditingController otpInput = TextEditingController();
    RxDouble secondsRemaining = 120.0.obs; // Countdown time in seconds
    RxBool isButtonDisabled = false.obs;
    RxBool isOTPExpired = false.obs;
    Timer? _timer;
    Timer? _otptimer;
    String? _otp;

    void startCountdown() {
      if (_timer != null) {
        _timer!.cancel();
      }

      secondsRemaining.value = 120; // Reset countdown
      isButtonDisabled.value = true; // Disable button

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          isButtonDisabled.value = false; // Re-enable button
          timer.cancel();
        }
      });
    }

    void startOTPCountdown() {
      if (_otptimer != null) {
        _otptimer!.cancel();
      }
      var expCounter = 300;
      _otptimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (expCounter > 0) {
          expCounter--;
        } else {
          isOTPExpired.value = true;
          timer.cancel();
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete account and data',
            style: GoogleFonts.poppins(
                color: AppStyles.primaryRed, fontWeight: FontWeight.w600),
          ),
          content: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text:
                              'Are you sure you want to delete your account and all associated data? '),
                      TextSpan(
                          text: 'This action is irreversible.',
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryRed,
                              fontWeight: FontWeight.w600)),
                    ]),
                    style: GoogleFonts.poppins(color: AppStyles.primaryBlack),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Enter your email to confirm:',
                    style: GoogleFonts.poppins(color: AppStyles.primaryBlack),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: emailInput,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryRed, fontSize: 16, height: 1),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: GoogleFonts.poppins(
                          color: AppStyles.lightGrey, fontSize: 16, height: 1),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppStyles.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppStyles.primaryRed),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Enter six (6) digit OTP:',
                    style: GoogleFonts.poppins(color: AppStyles.primaryBlack),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: otpInput,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6)
                          ],
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryRed,
                              fontSize: 16,
                              height: 1),
                          decoration: InputDecoration(
                            hintText: 'XXXXXX',
                            hintStyle: GoogleFonts.poppins(
                                color: AppStyles.lightGrey,
                                fontSize: 16,
                                height: 1),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: AppStyles.lightGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: AppStyles.primaryRed),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Obx(
                      () => TextButton(
                        onPressed: isButtonDisabled.value
                            ? null
                            : () async {
                                _otp = OTP.generateTOTPCodeString(
                                    AuthenticationRepository
                                        .instance.currentUserModel.value!.email,
                                    DateTime.now().millisecondsSinceEpoch);
                                await DatabaseRepository.instance.sendOTP(
                                    email: AuthenticationRepository
                                        .instance.currentUserModel.value!.email,
                                    otp: _otp!,
                                    username: AuthenticationRepository.instance
                                        .currentUserModel.value!.userName);
                                AppPopups.customToast(
                                    message:
                                        'OTP sent to ${AuthenticationRepository.instance.currentUserModel.value!.email}');
                                isOTPExpired.value = false;
                                startCountdown();
                                startOTPCountdown();
                              },
                        child: Text(
                          isButtonDisabled.value
                              ? 'Resend OTP in ${secondsRemaining.value}s' // Show countdown
                              : 'Send OTP',
                          style: GoogleFonts.poppins(
                              color: isButtonDisabled.value
                                  ? AppStyles.lightGrey
                                  : AppStyles.primaryRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppStyles.mediumGray),
              ),
            ),
            TextButton(
              onPressed: () async {
                final isConnected = await NetworkManager.instance.isConnected();
                if (!isConnected) {
                  AppPopups.customToast(message: 'No Internet Connection');
                  return;
                }
                try {
                  if (emailInput.text !=
                      AuthenticationRepository
                          .instance.currentUserModel.value!.email) {
                    return AppPopups.errorSnackBar(
                        title: 'Email incorrect',
                        message:
                            'Please enter the correct email address if you wish to proceed.');
                  }
                  if (isOTPExpired.value) {
                    return AppPopups.errorSnackBar(
                        title: 'OTP expired',
                        message: 'The OTP has expired. Please try again.');
                  }
                  if (otpInput.text != _otp) {
                    return AppPopups.errorSnackBar(
                        title: 'OTP incorrect',
                        message:
                            'Please enter the correct OTP if you wish to proceed.');
                  }
                  if (emailInput.text ==
                          AuthenticationRepository
                              .instance.currentUserModel.value!.email &&
                      otpInput.text == _otp &&
                      !isOTPExpired.value) {
                    AppPopups.openLoadingDialog(
                        'Deleting account...', AppConstants.aInFoundLoader);
                    await DatabaseRepository.instance.deleteAllUserData(
                        userId: AuthenticationRepository
                            .instance.currentUserModel.value!.uid);
                    await AuthenticationRepository.instance.signOut();
                    Get.offAllNamed(AppRoutes.login);
                  }
                } catch (e) {
                  AppPopups.errorSnackBar(
                      title: 'Error',
                      message:
                          'An error occurred while deleting your account. Please try again.');
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppStyles.primaryRed),
              ),
              child: Text(
                'Delete and sign out',
                style: GoogleFonts.poppins(
                    color: AppStyles.pureWhite, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class GrantRevokeWidget extends StatefulWidget {
  const GrantRevokeWidget({
    super.key,
    required this.badge,
  });
  final BadgeModel badge;

  @override
  State<GrantRevokeWidget> createState() => _GrantRevokeWidgetState();
}

class _GrantRevokeWidgetState extends State<GrantRevokeWidget> {
  List<UserModel> toGrantUsers = [];
  List<UserModel> toRevokeUsers = [];
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  Future getUsers() async {
    List<UserModel> usersFetch =
        await DatabaseRepository.instance.getAllUsers();
    setState(() {
      allUsers = usersFetch;
      sortAll();
    });
  }

  void sortGrant() {
    toGrantUsers.sort((a, b) => a.userName.compareTo(b.userName));
  }

  void sortRevoke() {
    toRevokeUsers.sort((a, b) => a.userName.compareTo(b.userName));
  }

  void sortAll() {
    allUsers.sort((a, b) => a.userName.compareTo(b.userName));
  }

  void filterUsers(String query) {
    if (query.isNotEmpty) {
      List<UserModel> tempUsers = [];
      allUsers.forEach((user) {
        if (user.userName.toLowerCase().contains(query.toLowerCase()) ||
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.uid.toLowerCase().contains(query.toLowerCase())) {
          tempUsers.add(user);
        }
      });
      setState(() {
        filteredUsers = tempUsers;
      });
      return;
    } else {
      setState(() {
        filteredUsers = [];
      });
    }
  }

  Future grantRevoke() async {
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppPopups.customToast(message: 'No Internet Connection');
      return;
    }

    if (toGrantUsers.isEmpty && toRevokeUsers.isEmpty) {
      AppPopups.customToast(message: 'No changes were made');
      return;
    }

    if (toGrantUsers.isNotEmpty) {
      AppPopups.openLoadingDialog(
          'Granting badges...', AppConstants.aInFoundLoader);
      try {
        for (UserModel user in toGrantUsers) {
          await DatabaseRepository.instance
              .grantBadge(userId: user.uid, badgeId: widget.badge.badgeId);
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(
            title: 'Error',
            message:
                'An error occurred while granting badges. Please try again.');
        return;
      }
      AppPopups.closeDialog();
    }

    if (toRevokeUsers.isNotEmpty) {
      AppPopups.openLoadingDialog(
          'Revoking badges...', AppConstants.aInFoundLoader);
      try {
        for (UserModel user in toRevokeUsers) {
          await DatabaseRepository.instance
              .revokeBadge(userId: user.uid, badgeId: widget.badge.badgeId);
        }
      } catch (e) {
        AppPopups.closeDialog();
        AppPopups.errorSnackBar(
            title: 'Error',
            message:
                'An error occurred while revoking badges. Please try again.');
        return;
      }
      AppPopups.closeDialog();
    }
    AppPopups.closeDialog();
    AppPopups.closeDialog();
    AppPopups.customToast(message: 'Granted/revoked badges successfully');
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: AppStyles.pureWhite),
      margin: EdgeInsets.only(right: 12, top: 12),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: double.infinity,
              height: 40,
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Text("Grant/revoke ${widget.badge.badgeTitle} badge",
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppStyles.primaryBlack)),
                  )),
                ],
              )),
          //Body
          Flexible(
            child: IntrinsicHeight(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: SingleChildScrollView(
                  child: Container(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppStyles.lightGrey.withAlpha(80),
                            ),
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.fromLTRB(24, 12, 16, 12),
                            child: Container(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: TextField(
                                  controller: searchController,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppStyles.primaryBlack),
                                  decoration: InputDecoration.collapsed(
                                    hintText: "Search",
                                    hintStyle: GoogleFonts.poppins(
                                        color: AppStyles.mediumGray),
                                  ),
                                  onChanged: (inp) {
                                    filterUsers(inp);
                                  },
                                )),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      filterUsers(searchController.text);
                                    },
                                    child: Icon(
                                      Icons.search,
                                      color: AppStyles.primaryTeal,
                                      size: 26,
                                    ),
                                  ),
                                )
                              ],
                            )),
                          ),
                          IntrinsicHeight(
                            child: Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (toGrantUsers.isNotEmpty)
                                      Padding(
                                        child: DividerWIthText(
                                          text: "To grant:",
                                          color: AppStyles.lightGrey,
                                          fontSize: 12,
                                          thickness: 2,
                                          space: 4,
                                        ),
                                        padding: EdgeInsets.only(bottom: 8),
                                      ),
                                    if (toGrantUsers.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (UserModel user in toGrantUsers)
                                              UserResultContainer(
                                                key: ValueKey(
                                                    user.uid + 'grant'),
                                                userModel: user,
                                                selectable: true,
                                                isChecked: true,
                                                onChange: (value) {
                                                  if (!value) {
                                                    if (mounted)
                                                      setState(() {
                                                        toGrantUsers
                                                            .remove(user);
                                                        allUsers.add(user);
                                                        sortAll();
                                                        if (searchController
                                                            .text.isNotEmpty) {
                                                          filterUsers(
                                                              searchController
                                                                  .text);
                                                        }
                                                      });
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (toRevokeUsers.isNotEmpty)
                                      Padding(
                                        child: DividerWIthText(
                                          text: "To revoke:",
                                          color: AppStyles.lightGrey,
                                          fontSize: 12,
                                          thickness: 2,
                                          space: 4,
                                        ),
                                        padding: EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                      ),
                                    if (toRevokeUsers.isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (UserModel user
                                                in toRevokeUsers)
                                              UserResultContainer(
                                                key: ValueKey(
                                                    user.uid + 'revoke'),
                                                userModel: user,
                                                selectable: true,
                                                isChecked: false,
                                                onChange: (value) {
                                                  if (value) {
                                                    if (mounted)
                                                      setState(() {
                                                        toRevokeUsers
                                                            .remove(user);
                                                        allUsers.add(user);
                                                        sortAll();
                                                        if (searchController
                                                            .text.isNotEmpty) {
                                                          filterUsers(
                                                              searchController
                                                                  .text);
                                                        }
                                                      });
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    Padding(
                                      child: DividerWIthText(
                                        text: "All users:",
                                        color: AppStyles.lightGrey,
                                        fontSize: 12,
                                        thickness: 2,
                                        space: 4,
                                      ),
                                      padding: EdgeInsets.only(
                                        bottom: 8,
                                      ),
                                    ),
                                    searchController.text == ''
                                        ? allUsers.isNotEmpty
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 8),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    for (UserModel user
                                                        in allUsers)
                                                      UserResultContainer(
                                                        key: ValueKey(
                                                            user.uid + "all"),
                                                        userModel: user,
                                                        selectable: true,
                                                        isChecked: user.badges
                                                            .contains(widget
                                                                .badge.badgeId),
                                                        onChange: (value) {
                                                          if (value) {
                                                            if (mounted)
                                                              setState(() {
                                                                toGrantUsers
                                                                    .add(user);
                                                                sortGrant();
                                                                allUsers.remove(
                                                                    user);
                                                                if (searchController
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  filterUsers(
                                                                      searchController
                                                                          .text);
                                                                }
                                                              });
                                                          } else {
                                                            if (mounted)
                                                              setState(() {
                                                                toRevokeUsers
                                                                    .add(user);
                                                                sortRevoke();
                                                                allUsers.remove(
                                                                    user);
                                                                if (searchController
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  filterUsers(
                                                                      searchController
                                                                          .text);
                                                                }
                                                              });
                                                          }
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                alignment: Alignment.center,
                                                child: EndOfResultContainer())
                                        : filteredUsers.isNotEmpty
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 8),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    for (UserModel user
                                                        in filteredUsers)
                                                      UserResultContainer(
                                                        key: ValueKey(user.uid +
                                                            "filtered"),
                                                        userModel: user,
                                                        selectable: true,
                                                        isChecked: user.badges
                                                            .contains(widget
                                                                .badge.badgeId),
                                                        onChange: (value) {
                                                          if (value) {
                                                            if (mounted)
                                                              setState(() {
                                                                toGrantUsers
                                                                    .add(user);
                                                                sortGrant();
                                                                allUsers.remove(
                                                                    user);
                                                                filteredUsers
                                                                    .remove(
                                                                        user);
                                                                if (searchController
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  filterUsers(
                                                                      searchController
                                                                          .text);
                                                                }
                                                              });
                                                          } else {
                                                            if (mounted)
                                                              setState(() {
                                                                toRevokeUsers
                                                                    .add(user);
                                                                sortRevoke();
                                                                allUsers.remove(
                                                                    user);
                                                                filteredUsers
                                                                    .remove(
                                                                        user);
                                                                if (searchController
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  filterUsers(
                                                                      searchController
                                                                          .text);
                                                                }
                                                              });
                                                          }
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                alignment: Alignment.center,
                                                child: EndOfResultContainer()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          //Footer
          Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            width: double.infinity,
            child: IntrinsicHeight(
                child: Container(
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButtonIcon(
                    onTap: (toGrantUsers.isNotEmpty || toRevokeUsers.isNotEmpty)
                        ? () async {
                            await grantRevoke();
                          }
                        : () {},
                    buttonColor:
                        (toGrantUsers.isNotEmpty || toRevokeUsers.isNotEmpty)
                            ? AppStyles.primaryTeal
                            : AppStyles.lightGrey,
                    height: 40,
                    buttonPadding: EdgeInsets.symmetric(horizontal: 16),
                    withIcon: false,
                    withText: true,
                    text: 'Grant/Revoke',
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
