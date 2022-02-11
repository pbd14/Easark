import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BookingScreen/components/place_info_screen.dart';
import 'package:easark/Screens/MapScreen/components/location_screen.dart';
import 'package:easark/Services/auth_service.dart';
import 'package:easark/Widgets/label_button.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String error;
  ProfileScreen({Key? key, this.error = 'Something Went Wrong'})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  List<DocumentSnapshot> favouritePlaces = [];
  // DocumentSnapshot? user;

  Future<void> prepare() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      for (String placeId in value.get('favourites')) {
        DocumentSnapshot middlePlace = await FirebaseFirestore.instance
            .collection('parking_places')
            .doc(placeId)
            .get();
        setState(() {
          favouritePlaces.add(middlePlace);
        });
      }
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    favouritePlaces = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.17,
                backgroundColor: whiteColor,
                centerTitle: true,
                actions: [
                  IconButton(
                    color: darkColor,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
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
                                  style: TextStyle(color: greenColor),
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
            body: RefreshIndicator(
              onRefresh: _refresh,
              color: darkColor,
              child: CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(
                          height: 40,
                        ),
                        if (FirebaseAuth.instance.currentUser!.phoneNumber !=
                            null)
                          Center(
                            child: Text(
                              FirebaseAuth.instance.currentUser!.phoneNumber
                                  .toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkColor,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        if (FirebaseAuth.instance.currentUser!.email != null)
                          Center(
                            child: Text(
                              FirebaseAuth.instance.currentUser!.email
                                  .toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkColor,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        for (DocumentSnapshot place in favouritePlaces)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            // padding: EdgeInsets.all(10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              margin: EdgeInsets.all(5),
                              elevation: 10,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: size.width * 0.45,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.get('name'),
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              place.get('city'),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: size.width * 0.35,
                                          child: Row(
                                            children: [
                                              favouritePlaces != null
                                                  ? Container(
                                                      width: 30,
                                                      child: LabelButton(
                                                        isC: false,
                                                        reverse: FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid),
                                                        containsValue: place.id,
                                                        color1: Colors.red,
                                                        color2:
                                                            lightPrimaryColor,
                                                        size: 24,
                                                        onTap: () {
                                                          setState(() {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .update({
                                                              'favourites':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                place.id
                                                              ])
                                                            });
                                                          });
                                                        },
                                                        onTap2: () {
                                                          setState(() {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .update({
                                                              'favourites':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                place.id
                                                              ])
                                                            });
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : Container(),
                                              IconButton(
                                                icon: Icon(
                                                  CupertinoIcons
                                                      .map_pin_ellipse,
                                                  color: darkPrimaryColor,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    SlideRightRoute(
                                                      page: LocationScreen(
                                                        data: {
                                                          'lat':
                                                              place.get('lat'),
                                                          'lon':
                                                              place.get('lon')
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  CupertinoIcons.book,
                                                  color: darkPrimaryColor,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    SlideRightRoute(
                                                      page: PlaceInfoScreen(
                                                        placeId: place.id,
                                                      ),
                                                    ),
                                                  );
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
