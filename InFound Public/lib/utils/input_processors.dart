import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infound/utils/styles.dart';
import 'package:intl/intl.dart';

class AppFormatter {
  static String approximateNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double result = number / 1000;
      return result.toStringAsFixed(result.toStringAsFixed(1).endsWith('0') ? 0 : 1) + 'k';
    } else {
      double result = number / 1000000;
      return result.toStringAsFixed(result.toStringAsFixed(1).endsWith('0') ? 0 : 1) + 'M';
    }
  }

  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('MM/dd/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm:ss').format(date);
    return '$onlyDate $onlyTime';
  }

  static String formatPhoneNumber(String phoneNo) {
    if (phoneNo.length == 11) {
      return '(+63) ${phoneNo.substring(1, 4)} ${phoneNo.substring(4, 7)} ${phoneNo.substring(7, 10)}';
    } else if (phoneNo.length == 10) {
      return '(+63) ${phoneNo.substring(0, 3)} ${phoneNo.substring(3, 6)} ${phoneNo.substring(6, 9)}';
    }
    return phoneNo;
  }

  static List<double> parseLocation(String location) {
    final loc = location.split('(').last;
    final parts = loc.split(', ').map((part) => part.replaceAll(')', '').replaceAll('m', '')).toList();
    return parts.map((part) => double.parse(part)).toList();
  }
}

class AlphanumericFormatter extends TextInputFormatter {
  final RegExp _regex = RegExp(r'[a-zA-Z0-9]'); // Allow only alphanumeric

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filteredText = newValue.text.split('').where((char) => _regex.hasMatch(char)).join();
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

String getFileExtension(XFile xFile) {
  String fileName = xFile.name;
  return fileName.contains('.') ? fileName.split('.').last : '';
}

bool isWithinRadius({
  required double centerLat,
  required double centerLon,
  required double pointLat,
  required double pointLon,
  required double radiusMeters,
}) {
  const double earthRadius = 6371000; // Earth's radius in meters

  // Convert degrees to radians
  double degToRad(double degrees) => degrees * pi / 180;

  // Haversine formula
  final double deltaLat = degToRad(pointLat - centerLat);
  final double deltaLon = degToRad(pointLon - centerLon);

  final double a =
      pow(sin(deltaLat / 2), 2) + cos(degToRad(centerLat)) * cos(degToRad(pointLat)) * pow(sin(deltaLon / 2), 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance between the two points
  final double distance = earthRadius * c;

  // Check if the distance is within the radius
  return distance <= radiusMeters;
}

/// Function to calculate distance between two lat-lon points in meters
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Earth's radius in meters

  // Convert degrees to radians
  double dLat = (lat2 - lat1) * pi / 180;
  double dLon = (lon2 - lon1) * pi / 180;

  // Convert latitudes to radians
  double radLat1 = lat1 * pi / 180;
  double radLat2 = lat2 * pi / 180;

  // Haversine formula
  double a = sin(dLat / 2) * sin(dLat / 2) + cos(radLat1) * cos(radLat2) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in meters
}

/// Function to check if a post is visible
bool isPostVisible({
  required double userLat,
  required double userLon,
  required double userRadius,
  required double postLat,
  required double postLon,
  required double postRadius,
}) {
  // Calculate the distance between the user and the post
  double distance = calculateDistance(userLat, userLon, postLat, postLon);

  // Check if the distance is within the combined visibility radius
  return distance <= (userRadius + postRadius);
}

Future<T?> waitForValue<T>(
  T? Function() checkValue, {
  required Duration timeout,
  Duration checkInterval = const Duration(milliseconds: 100),
}) async {
  final completer = Completer<T?>();

  Timer? timer;
  Timer? timeoutTimer;

  // Periodically check for the value
  timer = Timer.periodic(checkInterval, (timer) {
    final value = checkValue();
    if (value != null) {
      timer.cancel();
      timeoutTimer?.cancel();
      completer.complete(value);
    }
  });

  // Set the timeout
  timeoutTimer = Timer(timeout, () {
    timer?.cancel();
    completer.complete(null); // Return null if timeout occurs
  });

  return completer.future;
}

Future<DateTime?> selectDateTime({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String confirmText = 'SET',
}) async {
  // Show Date Picker
  DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2025, 1, 1, 0, 0, 0),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
              datePickerTheme: DatePickerThemeData(
            backgroundColor: AppStyles.bgGrey,
          )),
          child: child!,
        );
      });

  if (pickedDate != null) {
    // Show Time Picker after a date is selected
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppStyles.bgGrey,
              hourMinuteTextColor: Colors.teal,
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppStyles.primaryTealLightest;
                }
                return AppStyles.bgGrey;
              }),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppStyles.primaryTeal, width: 2),
              ),
              dayPeriodBorderSide: BorderSide(color: AppStyles.primaryTeal, width: 2),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              dialHandColor: AppStyles.primaryTealDarkest,
              dialBackgroundColor: AppStyles.primaryTealLightest,
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppStyles.bgGrey;
                }
                return AppStyles.primaryTeal;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppStyles.primaryTeal;
                }
                return AppStyles.bgGrey;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // Combine date and time into a single DateTime object
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
  }
  return null;
}

List<String> getSimilarBetweenLists(List<String> list1, List<String> list2) {
  return list1.where((element) => list2.contains(element)).toList();
}
