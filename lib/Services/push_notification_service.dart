import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future init() async {
    if (Platform.isIOS) {
      _fcm.requestPermission();
    }

    // NotificationSettings settings = await _fcm.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    String? token = await _fcm.getToken();
    if (FirebaseAuth.instance.currentUser != null) {
      if (kIsWeb) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'fcm_token_web': token,
        });
      }
      if (Platform.isAndroid) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'fcm_token_android': token,
        });
      }
      if (Platform.isIOS) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'fcm_token_ios': token,
        });
      }
    }

    // print("FirebaseMessaging token: $token");
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     // Navigator.of(context).push(SlideRightRoute(page: HistoryScreen()));
    //     // if (Platform.isAndroid) {
    //     PushNotificationMessage notification = PushNotificationMessage(
    //       title: message['notification']['title'],
    //       body: message['notification']['body'],
    //     );
    //     showSimpleNotification(
    //       Container(child: Text(notification.body)),
    //       position: NotificationPosition.top,
    //       background: darkPrimaryColor,
    //     );
    //     // }
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     if (Platform.isAndroid || Platform.isIOS) {
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //       );
    //       showSimpleNotification(
    //         Container(child: Text(notification.body)),
    //         position: NotificationPosition.top,
    //         background: darkPrimaryColor,
    //       );
    //     }
    //     if (Platform.isAndroid || Platform.isIOS) {
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //       );
    //       showSimpleNotification(
    //         Container(child: Text(notification.body)),
    //         position: NotificationPosition.top,
    //         background: darkPrimaryColor,
    //       );
    //     }
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     if (Platform.isAndroid || Platform.isIOS) {
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //       );
    //       showSimpleNotification(
    //         Container(child: Text(notification.body)),
    //         position: NotificationPosition.top,
    //         background: darkPrimaryColor,
    //       );
    //     }
    //     if (Platform.isAndroid || Platform.isIOS) {
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //       );
    //       showSimpleNotification(
    //         Container(child: Text(notification.body)),
    //         position: NotificationPosition.top,
    //         background: darkPrimaryColor,
    //       );
    //     }
    //   },
    // );
  }
}
