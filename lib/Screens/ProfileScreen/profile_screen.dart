import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BookingScreen/components/place_info_screen.dart';
import 'package:easark/Screens/MapScreen/components/location_screen.dart';
import 'package:easark/Services/auth_service.dart';
import 'package:easark/Widgets/label_button.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

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
  String? country;
  String? state;
  String? city;
  DocumentSnapshot? user;
  // DocumentSnapshot? user;

  Future<void> prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
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
                  // IconButton(
                  //   color: darkColor,
                  //   icon: Icon(CupertinoIcons.gear),
                  //   onPressed: () {
                  //     setState(() {
                  //       loading = true;
                  //     });
                  //     // Navigator.push(
                  //     //     context,
                  //     //     SlideRightRoute(
                  //     //       page: SettingsScreen(),
                  //     //     ));
                  //     setState(() {
                  //       loading = false;
                  //     });
                  //   },
                  // ),
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
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
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
                                overflow: TextOverflow.clip,
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
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkColor,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                          if (user!.get('status') == 'blocked')
                            SizedBox(
                              height: 20,
                            ),
                          if (user!.get('status') == 'blocked')
                            Center(
                              child: SizedBox(
                                width: size.width * 0.9,
                                child: Card(
                                  elevation: 10,
                                  margin: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 40,
                                        ),
                                        Text(
                                          "Your account was blocked",
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "We blocked your account because you left parking place without paying for it. Please check your bookings for unpaid ones and complete payments. Worker of the parking place should confirm your payment",
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              color: darkPrimaryColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: SizedBox(
                              width: size.width * 0.9,
                              child: Card(
                                elevation: 10,
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Text(
                                      "Location",
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Country: " + user!.get("country"),
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "State: " + user!.get("state"),
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "City: " + user!.get("city"),
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    RoundedButton(
                                      pw: 250,
                                      ph: 45,
                                      text: 'Change location',
                                      press: () async {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WillPopScope(
                                              onWillPop: () async => false,
                                              child: AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
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
                                                    flagState:
                                                        CountryFlag.DISABLE,
                                                    defaultCountry:
                                                        DefaultCountry
                                                            .Uzbekistan,
                                                    onCountryChanged: (value) {
                                                      setState(() {
                                                        country = value;
                                                      });
                                                    },
                                                    onStateChanged: (value) {
                                                      setState(() {
                                                        state = value;
                                                      });
                                                    },
                                                    onCityChanged: (value) {
                                                      setState(() {
                                                        city = value;
                                                      });
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
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user!.id)
                                                            .update({
                                                          'country': country,
                                                          'state': state,
                                                          'city': city,
                                                        }).catchError((error) {
                                                          print('ERRERF');
                                                          print(error);
                                                          isError = true;
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Fail',
                                                            body: 'Failed',
                                                          );
                                                          showSimpleNotification(
                                                            Text(notification
                                                                .body),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                Colors.red,
                                                          );
                                                        }).whenComplete(
                                                                () async {
                                                          if (!isError) {
                                                            PushNotificationMessage
                                                                notification =
                                                                PushNotificationMessage(
                                                              title: 'Success',
                                                              body:
                                                                  'Location is changed',
                                                            );
                                                            showSimpleNotification(
                                                              Text(notification
                                                                  .body),
                                                              position:
                                                                  NotificationPosition
                                                                      .top,
                                                              background:
                                                                  greenColor,
                                                            );
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                            _refresh();
                                                          }
                                                        });
                                                      }
                                                      ;
                                                    },
                                                    child: const Text(
                                                      'Ok',
                                                      style: TextStyle(
                                                          color: darkColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      color: darkPrimaryColor,
                                      textColor: whiteColor,
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                  ],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
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
                                            margin: EdgeInsets.only(right: 20),
                                            child: Row(
                                              children: [
                                                favouritePlaces != null
                                                    ? Container(
                                                        width: 30,
                                                        child: LabelButton(
                                                          isC: false,
                                                          reverse: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid),
                                                          containsValue:
                                                              place.id,
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
                                                            'lat': place
                                                                .get('lat'),
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
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
