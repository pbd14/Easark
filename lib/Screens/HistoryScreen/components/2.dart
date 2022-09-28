import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/label_button.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

class History2 extends StatefulWidget {
  @override
  _History2State createState() => _History2State();
}

class _History2State extends State<History2>
    with AutomaticKeepAliveClientMixin<History2> {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;
  List<QueryDocumentSnapshot> _bookings = [];
  Map _places = {};
  StreamSubscription<QuerySnapshot>? ordinaryPlacesSubscr;

  @override
  void dispose() {
    ordinaryPlacesSubscr!.cancel();
    super.dispose();
  }

  Future<void> ordinaryBookPrep(
      List<QueryDocumentSnapshot> _unrbookings1) async {
    // DocumentSnapshot customUB;
    if (_unrbookings1.isNotEmpty) {
      for (QueryDocumentSnapshot book in _bookings) {
        DocumentSnapshot data1 = await FirebaseFirestore.instance
            .collection('parking_places')
            .doc(book.get('place_id'))
            .get();
        setState(() {
          _places.addAll({
            book.id: data1.data(),
          });
        });
      }
    }
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    ordinaryPlacesSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_from',
          descending: true,
        )
        .where(
          'status',
          isEqualTo: 'finished',
        )
        .where(
          'client_id',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .limit(20)
        .snapshots()
        .listen((bookings) async {
      setState(() {
        _bookings = bookings.docs;
        ordinaryBookPrep(bookings.docs);
      });
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    _bookings = [];
    _places = {};
    loadData();
    Completer<void> completer = Completer<void>();
    completer.complete();
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : RefreshIndicator(
            color: darkColor,
            onRefresh: _refresh,
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                _bookings != null
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          for (QueryDocumentSnapshot book in _bookings)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              // padding: EdgeInsets.all(10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                margin: const EdgeInsets.all(5),
                                elevation: 10,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat.yMMMd()
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(book
                                                            .get(
                                                                'timestamp_from')
                                                            .millisecondsSinceEpoch))
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: darkDarkColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "ID: " + book.id,
                                                overflow: TextOverflow.clip,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: darkColor,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                Languages.of(context)!
                                                        .serviceScreenFrom +
                                                    ' ' +
                                                    DateFormat.yMMMd()
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(book
                                                                .get(
                                                                    'timestamp_from')
                                                                .millisecondsSinceEpoch))
                                                        .toString() +
                                                    ' ' +
                                                    DateFormat.yMMMd()
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(book
                                                                .get(
                                                                    'timestamp_from')
                                                                .millisecondsSinceEpoch))
                                                        .toString(),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: darkDarkColor,
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
                                                    ' ' +
                                                    DateFormat.yMMMd()
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(book
                                                                .get(
                                                                    'timestamp_to')
                                                                .millisecondsSinceEpoch))
                                                        .toString() +
                                                    ' ' +
                                                    DateFormat.yMMMd()
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(book
                                                                .get(
                                                                    'timestamp_to')
                                                                .millisecondsSinceEpoch))
                                                        .toString(),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: darkDarkColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Parking lot #' +
                                                    book
                                                        .get('space_id')
                                                        .toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                      color: darkDarkColor,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                book.get('status'),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: book.get('status') ==
                                                            'unfinished'
                                                        ? darkPrimaryColor
                                                        : Colors.red,
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
                                            width: size.width * 0.3,
                                            child: Column(
                                              children: [
                                                // if (_places[book.id] != null)
                                                // Label button is not working
                                                if(false)
                                                  LabelButton(
                                                    isC: false,
                                                    reverse: FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid),
                                                    containsValue:
                                                        _places[book.id]['id'],
                                                    color1: Colors.red,
                                                    color2: lightPrimaryColor,
                                                    size: 30,
                                                    onTap: () {
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .update({
                                                          'favourites':
                                                              FieldValue
                                                                  .arrayUnion([
                                                            _places[book.id].id
                                                          ])
                                                        }).catchError((error) {
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: Languages.of(
                                                                    context)!
                                                                .homeScreenFail,
                                                            body: Languages.of(
                                                                    context)!
                                                                .homeScreenFailedToUpdate,
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
                                                          if (mounted) {
                                                            setState(() {
                                                              loading = false;
                                                            });
                                                          } else {
                                                            loading = false;
                                                          }
                                                        });
                                                      });
                                                      PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: Languages.of(
                                                                    context)!
                                                                .homeScreenSaved,
                                                            body: Languages.of(
                                                                    context)!
                                                                .homeScreenSaved,
                                                          );
                                                          showSimpleNotification(
                                                            Text(notification
                                                                .body),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                darkColor,
                                                          );
                                                    },
                                                    onTap2: () {
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .update({
                                                          'favourites':
                                                              FieldValue
                                                                  .arrayRemove([
                                                            _places[book.id].id
                                                          ])
                                                        }).catchError((error) {
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: Languages.of(
                                                                    context)!
                                                                .homeScreenFail,
                                                            body: Languages.of(
                                                                    context)!
                                                                .homeScreenFailedToUpdate,
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
                                                          if (mounted) {
                                                            setState(() {
                                                              loading = false;
                                                            });
                                                          } else {
                                                            loading = false;
                                                          }
                                                        });
                                                      });
                                                      PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: Languages.of(
                                                                    context)!
                                                                .homeScreenSaved,
                                                            body: Languages.of(
                                                                    context)!
                                                                .homeScreenSaved,
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
                                                    },
                                                  )
                                                else
                                                  Container(),
                                                const SizedBox(height: 10),
                                                IconButton(
                                                  iconSize: 30,
                                                  icon: const Icon(
                                                    CupertinoIcons
                                                        .map_pin_ellipse,
                                                    color: darkPrimaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    // Navigator.push(
                                                    //   context,
                                                    //   SlideRightRoute(
                                                    //     page: MapPage(
                                                    //       isAppBar: true,
                                                    //       isLoading: true,
                                                    //       data: {
                                                    //         'lat': _places[Booking
                                                    //                     .fromSnapshot(
                                                    //                         book)
                                                    //                 .id]
                                                    //             .lat,
                                                    //         'lon': _places[Booking
                                                    //                     .fromSnapshot(
                                                    //                         book)
                                                    //                 .id]
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
                                                // IconButton(
                                                //   icon: Icon(
                                                //     CupertinoIcons.book,
                                                //     color: darkPrimaryColor,
                                                //   ),
                                                //   onPressed: ()  {
                                                //     setState(() {
                                                //       loading = true;
                                                //     });
                                                //     Navigator.push(
                                                //       context,
                                                //       SlideRightRoute(
                                                //         page: PlaceScreen(
                                                //           data: {
                                                //             'name':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .name, //0
                                                //             'description': Place
                                                //                     .fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                 .description, //1
                                                //             'by':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .by, //2
                                                //             'lat':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .lat, //3
                                                //             'lon':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .lon, //4
                                                //             'images':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .images, //5
                                                //             'services':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .services,
                                                //             'rates':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .rates,
                                                //             'id':
                                                //                 Place.fromSnapshot(
                                                //                         _results[
                                                //                             index])
                                                //                     .id, //7
                                                //           },
                                                //         ),
                                                //       ),
                                                //     );
                                                //     setState(() {
                                                //       loading = false;
                                                //     });
                                                //   },
                                                // ),
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
                          
                        ]),
                      )
                    : SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No history',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: darkPrimaryColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );

    
  }
}
