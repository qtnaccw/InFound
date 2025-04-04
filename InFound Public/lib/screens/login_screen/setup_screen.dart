import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infound/components/buttons.dart';
import 'package:infound/screens/login_screen/setup_controller.dart';
import 'package:infound/utils/input_processors.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/styles.dart';

class SetupScreen extends StatelessWidget {
  SetupScreen({super.key});

  final controller = Get.put(SetupController(), tag: 'SetupController');
  @override
  Widget build(BuildContext context) {
    return PopScope(
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
                Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: Text('Create a username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 28, fontWeight: FontWeight.w600, color: AppStyles.primaryTealLighter, height: 1)),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 4),
                  child: TextField(
                    controller: controller.usernameController,
                    inputFormatters: [AlphanumericFormatter()],
                    textAlign: TextAlign.center,
                    maxLength: 30,
                    style: GoogleFonts.poppins(
                        fontSize: 48, color: AppStyles.primaryBlack, fontWeight: FontWeight.w700, height: 1),
                    decoration: InputDecoration.collapsed(
                        hintText: "username001", hintStyle: GoogleFonts.poppins(color: AppStyles.lightGrey)),
                    onChanged: (value) {
                      controller.usernameResult.value = '';
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                  child: Obx(() {
                    if (controller.usernameResult.value != '') {
                      return Text(
                        controller.usernameResult.value,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: controller.usernameResult.value == "Username is available"
                                ? AppStyles.primaryTealLighter
                                : AppStyles.primaryRed,
                            fontWeight: FontWeight.w500,
                            height: 1),
                      );
                    } else {
                      return Container();
                    }
                  }),
                ),
                SizedBox(height: 20),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Theme(
                          data: ThemeData(
                            unselectedWidgetColor: AppStyles.lightGrey,
                          ),
                          child: Checkbox(
                              value: controller.privacyPolicyAccepted.value,
                              onChanged: (value) {
                                controller.privacyPolicyAccepted.value = value!;
                              },
                              activeColor: AppStyles.primaryTeal,
                              checkColor: AppStyles.pureWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Accept our',
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryBlack, fontSize: 16, fontWeight: FontWeight.w500, height: 1),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Privacy Policy',
                          style: GoogleFonts.poppins(
                              color: AppStyles.primaryTeal, fontSize: 16, fontWeight: FontWeight.w500, height: 1),
                        ),
                        onPressed: () {
                          AppPopups.openPrivacyStatement();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  width: 200,
                  child: MaterialButtonIcon(
                    onTap: () async {
                      if (controller.usernameController.text.isEmpty) {
                        controller.usernameResult.value = 'Username cannot be empty';
                        return;
                      } else {
                        AppPopups.popUpCircular();
                        await controller.checkUsername(controller.usernameController.text).then((value) {
                          AppPopups.closeDialog();
                        });
                        if (controller.usernameResult.value == "Username is available") {
                          controller.setupUser(context);
                        }
                      }
                    },
                    withIcon: false,
                    withText: true,
                    text: 'USE THIS USERNAME',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
