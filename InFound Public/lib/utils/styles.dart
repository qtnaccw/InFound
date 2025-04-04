import 'package:flutter/material.dart';

class AppStyles {
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color muteBlack = Color(0xFF404040);
  static const Color mediumGray = Color.fromARGB(255, 145, 145, 145);
  static const Color lightGrey = Color.fromARGB(255, 189, 189, 189);

  static const Color bgGrey = Color(0xFFf6f6f6);

  static const Color primaryBlue = Color(0xFF303244);
  static const Color primaryBlack = Color(0xFF404040);

  static const Color primaryTeal = Color(0xFF5BB6AE);
  static const Color primaryTealDarker = Color.fromARGB(255, 40, 141, 133);
  static const Color primaryTealDarkest = Color.fromARGB(255, 15, 78, 73);
  static const Color primaryTealLighter = Color.fromARGB(255, 145, 214, 208);
  static const Color primaryTealLightest = Color(0xFFDFF0EF);

  static const Color primaryRed = Color.fromARGB(255, 226, 140, 140);
  static const Color primaryYellow = Color.fromARGB(255, 233, 231, 114);
  static const Color primaryGreen = Color.fromARGB(255, 125, 218, 141);

  static const Color primaryBronze = Color.fromARGB(255, 137, 89, 41);
  static const Color primarySilver = Color.fromARGB(255, 192, 192, 192);
  static const Color primaryGold = Color.fromARGB(255, 182, 163, 52);
  static const Color primaryPlatinum = Color.fromARGB(255, 70, 175, 188);
  static const Color primaryDiamond = Color.fromARGB(255, 167, 66, 140);

  lightBoxShadow(Color color) {
    return BoxShadow(color: color, blurRadius: 15, spreadRadius: -10);
  }
}
