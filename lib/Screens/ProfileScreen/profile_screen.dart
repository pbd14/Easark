import 'package:easark/Services/auth_service.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Scaffold(
      appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.17,
                backgroundColor: whiteColor,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.gear),
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      // Navigator.push(
                      //     context,
                      //     SlideRightRoute(
                      //       page: SettingsScreen(),
                      //     ));
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                  IconButton(
                    color: darkColor,
                    icon: Icon(
                      Icons.exit_to_app,
                    ),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // title: Text(
                            //     Languages.of(context).profileScreenSignOut),
                            // content: Text(
                            //     Languages.of(context)!.profileScreenWantToLeave),
                            title: Text('Sign Out?'),
                            content: Text('Sure?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  // prefs.setBool('local_auth', false);
                                  // prefs.setString('local_password', '');
                                  Navigator.of(context).pop(true);
                                  AuthService().signOut(context);
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'No',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]),
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
