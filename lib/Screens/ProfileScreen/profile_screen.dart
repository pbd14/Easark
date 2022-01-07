import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String error;
  ProfileScreen({Key? key, this.error = 'Something Went Wrong'})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
