import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BusinessScreen/booking_management_screen.dart';
import 'package:easark/Screens/BusinessScreen/business_screen.dart';
import 'package:easark/Screens/BusinessScreen/core_screen.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/Widgets/sww_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class SpaceScreen extends StatefulWidget {
  String placeId;
  int spaceId;
  SpaceScreen({Key? key, required this.placeId, required this.spaceId})
      : super(key: key);

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  bool loading = true;
  bool isDeleted = false;
  DocumentSnapshot? place;
  QuerySnapshot? bookings;
  Map space = {};

  Future<void> prepare() async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .where('place_id', isEqualTo: widget.placeId)
        .where('space_id', isEqualTo: widget.spaceId)
        .get()
        .then((value) {
      setState(() {
        bookings = value;
      });
    });
    await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get()
        .then((value) {
      setState(() {
        place = value;
        loading = false;
        // List spaces = [];
        // spaces.where((element) => element['id'] == widget.spaceId).first;
        space = value
            .get('spaces')
            .where((element) => element['id'] == widget.spaceId)
            .first;
      });
    });
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
        ? const LoadingScreen()
        : isDeleted
            ? SomethingWentWrongScreen(
                error: 'DELETED',
              )
            : SingleChildScrollView(
                child: Container(
                  color: const Color.fromRGBO(247, 247, 247, 1.0),
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            !space['isFree']
                                ? 'assets/images/parking1.png'
                                : space['isActive']
                                    ? 'assets/images/parking2.png'
                                    : 'assets/images/parking3.png',
                            width: 100,
                            fit: BoxFit.fitWidth,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "#" + widget.spaceId.toString() + ' parking lot',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: darkPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      space['isFree']
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RoundedButton(
                                  pw: 120,
                                  ph: 45,
                                  text: space['isActive']
                                      ? 'DEACTIVATE'
                                      : 'ACTIVATE',
                                  press: () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    List spaces = [];
                                    DocumentSnapshot middlePlace =
                                        await FirebaseFirestore.instance
                                            .collection('parking_places')
                                            .doc(widget.placeId)
                                            .get();
                                    spaces = middlePlace.get('spaces');
                                    setState(() {
                                      space['isActive'] = !space['isActive'];
                                      spaces[spaces.indexOf(spaces
                                          .where((element) =>
                                              element['id'] == space['id'])
                                          .first)] = space;
                                    });
                                    FirebaseFirestore.instance
                                        .collection('parking_places')
                                        .doc(widget.placeId)
                                        .update({
                                      'spaces': spaces,
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to update',
                                      );
                                      showSimpleNotification(
                                        Text(notification.body),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                      if (mounted) {
                                        setState(() {
                                          space['isActive'] =
                                              !space['isActive'];
                                          loading = false;
                                        });
                                      } else {
                                        space['isActive'] = !space['isActive'];
                                        loading = false;
                                      }
                                    });
                                    if (mounted) {
                                      setState(() {
                                        loading = false;
                                      });
                                    } else {
                                      loading = false;
                                    }
                                  },
                                  color: lightPrimaryColor,
                                  textColor: whiteColor,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                RoundedButton(
                                  pw: 100,
                                  ph: 45,
                                  text: 'DELETE',
                                  press: () {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          title: const Text('Delete?'),
                                          content: const Text(
                                              'Are your sure you want to delete this parking place?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async {
                                                setState(() {
                                                  loading = true;
                                                });
                                                // List spaces = [];
                                                // DocumentSnapshot middlePlace =
                                                //     await FirebaseFirestore
                                                //         .instance
                                                //         .collection(
                                                //             'parking_places')
                                                //         .doc(widget.placeId)
                                                //         .get();
                                                // spaces =
                                                //     middlePlace.get('spaces');
                                                // spaces.remove(space);
                                                // print("ERERTET");
                                                // print(spaces);
                                                // print(space);
                                                setState(() {
                                                  isDeleted = true;
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'parking_places')
                                                    .doc(widget.placeId)
                                                    .update({
                                                  'spaces':
                                                      FieldValue.arrayRemove(
                                                          [space]),
                                                }).catchError((error) {
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Fail',
                                                    body: 'Failed to delete',
                                                  );
                                                  showSimpleNotification(
                                                    Text(notification.body),
                                                    position:
                                                        NotificationPosition
                                                            .top,
                                                    background: Colors.red,
                                                  );
                                                  if (mounted) {
                                                    setState(() {
                                                      isDeleted = false;
                                                      loading = false;
                                                    });
                                                  } else {
                                                    isDeleted = false;
                                                    loading = false;
                                                  }
                                                });
                                                if (mounted) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                } else {
                                                  loading = false;
                                                }

                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  color: Colors.red,
                                  textColor: whiteColor,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 60,
                      ),
                      Text(
                        'Bookings',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: darkColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          for (QueryDocumentSnapshot booking in bookings!.docs)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: BookingManagementScreen(
                                        bookingId: booking.id,
                                      ),
                                    ));
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  color: whiteColor,
                                  margin: const EdgeInsets.all(5),
                                  elevation: 10,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat.yMMMd()
                                                      .format(booking
                                                          .get('timestamp_from')
                                                          .toDate())
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  Languages.of(context)!
                                                          .serviceScreenFrom +
                                                      '\n' +
                                                      DateFormat.yMMMd()
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(booking
                                                                  .get(
                                                                      'timestamp_from')
                                                                  .millisecondsSinceEpoch))
                                                          .toString() +
                                                      ' ' +
                                                      DateFormat.Hm()
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(booking
                                                                  .get(
                                                                      'timestamp_from')
                                                                  .millisecondsSinceEpoch))
                                                          .toString(),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  Languages.of(context)!
                                                          .serviceScreenTo +
                                                      '\n' +
                                                      DateFormat.yMMMd()
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(booking
                                                                  .get(
                                                                      'timestamp_to')
                                                                  .millisecondsSinceEpoch))
                                                          .toString() +
                                                      ' ' +
                                                      DateFormat.Hm()
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(booking
                                                                  .get(
                                                                      'timestamp_to')
                                                                  .millisecondsSinceEpoch))
                                                          .toString(),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Parking lot #' +
                                                      booking
                                                          .get('space_id')
                                                          .toString(),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                        color: darkColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  booking.get('status'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: SizedBox(
                                              width: size.width * 0.2,
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    iconSize: 30,
                                                    icon: const Icon(
                                                      CupertinoIcons
                                                          .map_pin_ellipse,
                                                      color: darkColor,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      // Navigator.push(
                                                      //   context,
                                                      //   SlideRightRoute(
                                                      //     page: MapPage(
                                                      //       isLoading: true,
                                                      //       isAppBar: true,
                                                      //       data: {
                                                      //         'lat': Place.fromSnapshot(
                                                      //                 inprocessPlacesSlivers[
                                                      //                     book])
                                                      //             .lat,
                                                      //         'lon': Place.fromSnapshot(
                                                      //                 inprocessPlacesSlivers[
                                                      //                     book])
                                                      //             .lon
                                                      //       },
                                                      //     ),
                                                      //   ),
                                                      // );
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
                            ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.2,
                      ),
                    ],
                  ),
                ),
              );
  }
}
