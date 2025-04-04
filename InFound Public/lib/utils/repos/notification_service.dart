import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infound/models/notification_model.dart';
import 'package:infound/utils/popups.dart';
import 'package:infound/utils/repos/authentication_repository.dart';

class NotificationService with ChangeNotifier {
  int notificationCount = 0;
  List<NotificationModel> notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationListener;

  // Start listening for notifications on app startup if a user is logged in
  void listenForNotifications() {
    final currentUser = AuthenticationRepository.instance.currentUserModel.value;

    if (currentUser != null) {
      _notificationListener?.cancel();

      _notificationListener = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("notifications") // Only fetch user-specific notifications
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((snapshot) {
        notifications = snapshot.docs.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
        notificationCount = notifications.where((notf) => !notf.read).length;
        notifyListeners();

        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              String type = change.doc["type"];
              String username = change.doc["senderUsername"];
              String content = change.doc["notifContent"];

              DateTime dateTime = change.doc["createdAt"].toDate();
              bool read = change.doc["read"] ?? true;

              DateTime withinMinute = DateTime.now().subtract(Duration(seconds: 30));
              if (dateTime.isAfter(withinMinute) && !read) {
                AppPopups.notificationSnackbar(
                  title: type == "LIKE"
                      ? "Upvote notification"
                      : type == "COMMENT"
                          ? "Comment notification"
                          : type == "REPLY"
                              ? "Reply notification"
                              : type == "BADGE"
                                  ? "Badge notification"
                                  : type == "USERREQUEST"
                                      ? "Request notification"
                                      : "Notification",
                  message: "$username $content",
                );
              }
            }
          }
        }
      });
    }
  }

  // Call this in your widget's initState to start listening
  void startListeningForNotificationsIfNeeded() {
    final currentUser = AuthenticationRepository.instance.currentUserModel.value;
    if (currentUser != null && notifications.isEmpty) {
      listenForNotifications(); // Start listening if user exists
    }
  }

  void markAsRead(String notificationId) async {
    NotificationModel temp =
        notifications[notifications.indexWhere((element) => element.notifId == notificationId)].copyWith(read: true);
    notifications[notifications.indexWhere((element) => element.notifId == notificationId)] = temp;
    notificationCount = notifications.where((notf) => !notf.read).length;
    notifyListeners();
  }

  markAsUnread(String notificationId) async {
    NotificationModel temp =
        notifications[notifications.indexWhere((element) => element.notifId == notificationId)].copyWith(read: false);
    notifications[notifications.indexWhere((element) => element.notifId == notificationId)] = temp;
    notificationCount = notifications.where((notf) => !notf.read).length;
    notifyListeners();
  }

  markAllAsRead() async {
    for (var notf in notifications) {
      if (!notf.read) {
        markAsRead(notf.notifId);
      }
    }
    notifyListeners();
  }

  markAllAsUnread() async {
    for (var notf in notifications) {
      if (notf.read) {
        markAsUnread(notf.notifId);
      }
    }
    notifyListeners();
  }

  deleteAllNotifications() async {
    notifications.clear();
    notificationCount = 0;
    notifyListeners();
  }

  void stopListening() {
    _notificationListener?.cancel(); // 🔹 Cancel Firestore listener
    _notificationListener = null;
    notifications.clear(); // 🔹 Clear old notifications
    notificationCount = 0; // 🔹 Reset unread count
    notifyListeners();
  }
}
