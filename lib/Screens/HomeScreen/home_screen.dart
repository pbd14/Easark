import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/MapScreen/map_screen.dart';
import 'package:easark/Screens/ProfileScreen/profile_screen.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  String error;
  HomeScreen({Key? key, this.error = 'Something Went Wrong'}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      MapScreen(),
      ProfileScreen(),
    ];
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
        icon: const Icon(CupertinoIcons.person),
        title: ("Settings"),
        activeColorPrimary: whiteColor,
        activeColorSecondary: whiteColor,
        inactiveColorPrimary: const Color.fromRGBO(200, 200, 200, 1.0),
      ),
    ];
  }

  @override
  void initState() {
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
