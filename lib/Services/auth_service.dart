import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/HomeScreen/home_screen.dart';
import 'package:easark/Screens/LoginScreen/login_screen.dart';
import 'package:easark/Services/push_notification_service.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/Widgets/sww_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final pushNotificationService =
                PushNotificationService(_firebaseMessaging);
            pushNotificationService.init();
            return HomeScreen();
          } else {
            return const LoginScreen();
          }
        });
  }

  signOut(BuildContext context) {
    dynamic res = FirebaseAuth.instance.signOut().catchError((error) {
      Navigator.push(
          context,
          SlideRightRoute(
              page: SomethingWentWrongScreen(
            error: "Failed to sign out: ${error.message}", key: null,
          )));
    });
    return res;
  }

  signIn(PhoneAuthCredential authCredential, BuildContext context) {
    try {
      dynamic res = FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .catchError((error) {
        Navigator.push(
            context,
            SlideRightRoute(
                page: SomethingWentWrongScreen(
              error: "Something went wrong: ${error.message}",
            )));
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        'status': 'default',
        'cancellations_num': 0,
        'phone': FirebaseAuth.instance.currentUser?.phoneNumber,
      });
      final pushNotificationService =
          PushNotificationService(_firebaseMessaging);
      pushNotificationService.init();
      return res;
    } catch (e) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({'status': 'not logged in'});
      return null;
    }
  }

  signInWithOTP(smsCode, verId, BuildContext context) {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      dynamic res = signIn(authCredential, context);
      return res;
    } catch (e) {
      return null;
    }
  }
}
