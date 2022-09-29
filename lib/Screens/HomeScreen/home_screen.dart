import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BusinessScreen/core_screen.dart';
import 'package:easark/Screens/HistoryScreen/history_screen.dart';
import 'package:easark/Screens/MapScreen/map_screen.dart';
import 'package:easark/Screens/ProfileScreen/profile_screen.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  int tabNum;
  HomeScreen({
    Key? key,
    this.tabNum = 0,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? country;
  String? state;
  String? city;
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      if (!kIsWeb) MapScreen(),
      CoreScreen(),
      HistoryScreen(),
      ProfileScreen(),
    ];
  }

  void changeTabNumber(int number) {
    _controller.jumpToTab(number);
  }

  void checkUserValidity() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (
      user.get('country') == null ||
        user.get('state') == null ||
        user.get('city') == null ||
        user.get('country').isEmpty ||
        user.get('state').isEmpty ||
        user.get('city').isEmpty ||
        user.get('country') == '' ||
        user.get('state') == '' ||
        user.get('city') == '') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // title: Text(
              //     Languages.of(context).profileScreenSignOut),
              // content: Text(
              //     Languages.of(context)!.profileScreenWantToLeave),
              title: Text(
                'Select your location',
              ),
              content: SizedBox(
                width: 300,
                height: 300,
                child: CSCPicker(
                  flagState: CountryFlag.DISABLE,
                  defaultCountry: DefaultCountry.Uzbekistan,
                  onCountryChanged: (value) {
                    if (mounted) {
                      setState(() {
                        country = value;
                      });
                    }
                  },
                  onStateChanged: (value) {
                    if (mounted) {
                      setState(() {
                        state = value;
                      });
                    }
                  },
                  onCityChanged: (value) {
                    if (mounted) {
                      setState(() {
                        city = value;
                      });
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    bool isError = false;
                    if (country != null &&
                        city != null &&
                        state != null &&
                        country!.isNotEmpty &&
                        state!.isNotEmpty &&
                        city!.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({
                        'country': country,
                        'state': state,
                        'city': city,
                      }).catchError((error) {
                        print('ERRERF');
                        print(error);
                        isError = true;
                        PushNotificationMessage notification =
                            PushNotificationMessage(
                          title: 'Fail',
                          body: 'Failed',
                        );
                        showSimpleNotification(
                          Text(notification.body),
                          position: NotificationPosition.top,
                          background: Colors.red,
                        );
                      }).whenComplete(() {
                        Navigator.of(context).pop(false);
                      });
                    }
                    ;
                  },
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: darkColor),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (user.get('status') == 'blocked') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // title: Text(
              //     Languages.of(context).profileScreenSignOut),
              // content: Text(
              //     Languages.of(context)!.profileScreenWantToLeave),
              title: Text(
                'Blocked',
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                  'Your account was blocked. Please check if you have paid for all of your bookings. Contact us for more info.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: darkColor),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    if (FirebaseAuth.instance.currentUser!.email != null) {
      if (FirebaseAuth.instance.currentUser!.email!.isNotEmpty) {
        if (FirebaseAuth.instance.currentUser != null &&
            !FirebaseAuth.instance.currentUser!.emailVerified) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  // title: Text(
                  //     Languages.of(context).profileScreenSignOut),
                  // content: Text(
                  //     Languages.of(context)!.profileScreenWantToLeave),
                  title: Text(
                    'Verify your email',
                    style: TextStyle(color: Colors.red),
                  ),
                  content: Text(
                      'Please verify your email. Check if verfication email is in the spam box.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        bool isError = false;
                        FirebaseAuth.instance.currentUser!
                            .sendEmailVerification()
                            .catchError((error) {
                          print('ERRERF');
                          print(error);
                          isError = true;
                          PushNotificationMessage notification =
                              PushNotificationMessage(
                            title: 'Fail',
                            body: 'Failed to send email',
                          );
                          showSimpleNotification(
                            Text(notification.body),
                            position: NotificationPosition.top,
                            background: Colors.red,
                          );
                        }).whenComplete(() {
                          if (!isError) {
                            PushNotificationMessage notification =
                                PushNotificationMessage(
                              title: 'Success',
                              body: 'Email was sent',
                            );
                            showSimpleNotification(
                              Text(notification.body),
                              position: NotificationPosition.top,
                              background: greenColor,
                            );
                          }
                        });
                      },
                      child: const Text(
                        'Resend email',
                        style: TextStyle(color: darkColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.currentUser?.reload();
                        if (FirebaseAuth.instance.currentUser != null &&
                            FirebaseAuth.instance.currentUser!.emailVerified) {
                          Navigator.of(context).pop(false);
                        }
                      },
                      child: const Text(
                        'Check if Verified',
                        style: TextStyle(color: darkColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }
    }
  }

  Future<void> checkUserProfile() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (!user.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        'id': FirebaseAuth.instance.currentUser?.uid,
        'status': 'default',
        'phone': FirebaseAuth.instance.currentUser?.phoneNumber,
        'email': FirebaseAuth.instance.currentUser?.email,
        'favourites': [],
        'country': '',
        'state': '',
        'city': '',
      }).whenComplete(() {
        checkUserValidity();
      });
    } else {
      checkUserValidity();
    }
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      if (!kIsWeb)
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.map),
          title: ("Home"),
          activeColorPrimary: whiteColor,
          activeColorSecondary: whiteColor,
          inactiveColorPrimary: const Color.fromRGBO(200, 200, 200, 1.0),
        ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.money_dollar_circle),
        title: ("Business"),
        activeColorPrimary: whiteColor,
        activeColorSecondary: whiteColor,
        inactiveColorPrimary: const Color.fromRGBO(200, 200, 200, 1.0),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.clock),
        title: ("History"),
        activeColorPrimary: whiteColor,
        activeColorSecondary: whiteColor,
        inactiveColorPrimary: const Color.fromRGBO(200, 200, 200, 1.0),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person),
        title: ("Profile"),
        activeColorPrimary: whiteColor,
        activeColorSecondary: whiteColor,
        inactiveColorPrimary: const Color.fromRGBO(200, 200, 200, 1.0),
      ),
    ];
  }

  @override
  void initState() {
    checkUserProfile();
    if (widget.tabNum != 0) {
      _controller.jumpToTab(widget.tabNum);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: darkColor, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(40.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style13,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    );
  }
}
