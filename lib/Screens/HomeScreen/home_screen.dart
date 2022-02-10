import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/core_screen.dart';
import 'package:easark/Screens/HistoryScreen/history_screen.dart';
import 'package:easark/Screens/MapScreen/map_screen.dart';
import 'package:easark/Screens/ProfileScreen/profile_screen.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      MapScreen(),
      CoreScreen(),
      HistoryScreen(),
      ProfileScreen(),
    ];
  }

  void changeTabNumber(int number) {
    _controller.jumpToTab(number);
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
      });
    } else {
      if (user.get('status') == 'blocked') {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
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
            );
          },
        );
      }
    }
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
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
    if (widget.tabNum != 0) {
      _controller.jumpToTab(widget.tabNum);
    }
    checkUserProfile();
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
