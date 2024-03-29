import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BookingScreen/components/place_info_screen.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_map_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:overlay_support/overlay_support.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  String error;
  MapScreen({Key? key, this.error = 'Something Went Wrong'}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double pinPillPosition = -100;
  double searchButtonPosition = -200;
  double mapZoom = 15;
  bool loading = false;
  bool loading1 = true;
  String? country;
  String? state;
  String? city;
  Set<Marker> _markers = HashSet<Marker>();
  List<QueryDocumentSnapshot>? places;
  DocumentSnapshot? user;
  GoogleMapController? _mapController;
  // ignore: avoid_init_to_null
  static LatLng _initialPosition =
      const LatLng(41.36426966573496, 69.21005744487047);
  LatLng? cameraPosition;
  BitmapDescriptor? pinLocationIcon;
  String currentPinInfo = 'Loading ...';
  String? pinId;

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    _getUserLocation();
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    prepare();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _getUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
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
                  'Enable location',
                  style: TextStyle(color: Colors.red),
                ),
                content: Text(
                    'Our app needs your location to work. Please turn on your location. We will not share your location with anyone and will not store it anywhere except your phone.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.granted) {
                        Navigator.of(context).pop(false);
                        _refresh();
                      }
                      setState(() {
                        loading = false;
                      });
                    },
                    child: const Text(
                      'I turned on location',
                      style: TextStyle(color: darkColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );

        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
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
                  'Location access',
                  style: TextStyle(color: Colors.red),
                ),
                content: Text(
                    'Our app needs your PRECISE location to work. Please grant access to it in settings of the phone. We will not share your location with anyone and will not store it anywhere except your phone.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.granted) {
                        Navigator.of(context).pop(false);
                        _refresh();
                      }
                      setState(() {
                        loading = false;
                      });
                    },
                    child: const Text(
                      'I gave access',
                      style: TextStyle(color: darkColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );

        return;
      }
    }

    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.best);
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        cameraPosition = _initialPosition;
        loading1 = false;
      });
    }
  }

  // void _getUserLocation() async {
  //   geolocator.Position position =
  //       await geolocator.Geolocator.getCurrentPosition(
  //           desiredAccuracy: geolocator.LocationAccuracy.high);
  //   if (mounted) {
  //     setState(() {
  //       _initialPosition = LatLng(position.latitude, position.longitude);
  //       cameraPosition = _initialPosition;
  //       loading1 = false;
  //     });
  //   }
  // }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    _mapController?.setMapStyle(style);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      loading = false;
    });
    _setMapStyle();
  }

  void prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (user!.exists) {
      if (user!.get('country') == null ||
          user!.get('state') == null ||
          user!.get('city') == null ||
          user!.get('country').isEmpty ||
          user!.get('state').isEmpty ||
          user!.get('city').isEmpty ||
          user!.get('country') == '' ||
          user!.get('state') == '' ||
          user!.get('city') == '') {
        PushNotificationMessage notification = PushNotificationMessage(
          title: 'Fail',
          body: 'Set your location for profile',
        );
        showSimpleNotification(
          Text(notification.body),
          position: NotificationPosition.top,
          background: Colors.red,
        );
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      } else {
        country = user!.get('country');
        state = user!.get('state');
        city = user!.get('city');
        QuerySnapshot data = await FirebaseFirestore.instance
            .collection('parking_places')
            .where('country', isEqualTo: user!.get('country'))
            .where('state', isEqualTo: user!.get('state'))
            .where('city', isEqualTo: user!.get('city'))
            .where('is_active', isEqualTo: true)
            .get();
        setState(() {
          places = data.docs;
        });
        if (places!.isEmpty) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'No parking',
            body: 'There are no parking places near you',
          );
          showSimpleNotification(
            Text(notification.body),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        }
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const LoadingScreen()
          : Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                loading1
                    ? const LoadingMapScreen()
                    : GoogleMap(
                        mapType: MapType.normal,
                        minMaxZoomPreference:
                            const MinMaxZoomPreference(5.0, 40.0),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapToolbarEnabled: false,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: mapZoom,
                        ),
                        markers: _markers,
                        onTap: (LatLng location) {
                          setState(() {
                            currentPinInfo = 'Loading ...';
                            pinPillPosition = -100;
                          });
                        },
                        onCameraMove: (position) {
                          setState(() {
                            searchButtonPosition = -200;
                            cameraPosition = position.target;
                          });
                        },
                        onCameraIdle: () {
                          setState(() {
                            searchButtonPosition = 50;
                          });
                        },
                      ),
                AnimatedPositioned(
                  top: searchButtonPosition,
                  right: 0,
                  left: 0,
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: CupertinoButton(
                                onPressed: () async {
                                  Set<Marker> middleMarkers = HashSet<Marker>();
                                  QuerySnapshot updatePlaces =
                                      await FirebaseFirestore.instance
                                          .collection('parking_places')
                                          .where('country',
                                              isEqualTo: user!.get('country'))
                                          .where('state',
                                              isEqualTo: user!.get('state'))
                                          .where('city',
                                              isEqualTo: user!.get('city'))
                                          .where('is_active', isEqualTo: true)
                                          .get();
                                  setState(() {
                                    places = updatePlaces.docs;
                                  });
                                  for (QueryDocumentSnapshot place in places!) {
                                    if (geolocator.Geolocator.distanceBetween(
                                            cameraPosition!.latitude,
                                            cameraPosition!.longitude,
                                            place.get('lat'),
                                            place.get('lon')) <=
                                        2000) {
                                      pinLocationIcon =
                                          await BitmapDescriptor.fromAssetImage(
                                        const ImageConfiguration(
                                            devicePixelRatio: 3),
                                        'assets/icons/marker.png',
                                      );
                                      middleMarkers.add(
                                        Marker(
                                          markerId: MarkerId(place.id),
                                          position: LatLng(place.get('lat'),
                                              place.get('lon')),
                                          onTap: () async {
                                            await _mapController?.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: LatLng(
                                                    place.get('lat') - 0.0001,
                                                    place.get('lon'),
                                                  ),
                                                  zoom: 15,
                                                ),
                                              ),
                                            );
                                            setState(() {
                                              if (place.get('isppm')) {
                                                currentPinInfo = place
                                                        .get('price')
                                                        .toString() +
                                                    ' ' +
                                                    place.get('currency') +
                                                    ' per minute';
                                              } else if (place
                                                  .get('isFixedPrice')) {
                                                currentPinInfo = place
                                                        .get('price')
                                                        .toString() +
                                                    ' ' +
                                                    place.get('currency') +
                                                    ' fixed price';
                                              }

                                              pinId = place.id;
                                              pinPillPosition = 100;
                                            });
                                          },
                                          icon: pinLocationIcon!,
                                        ),
                                      );
                                    }
                                  }
                                  setState(() {
                                    _markers = {};
                                    _markers = middleMarkers;
                                    middleMarkers = {};
                                    _mapController?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            cameraPosition!.latitude,
                                            cameraPosition!.longitude,
                                          ),
                                          zoom: 13.5,
                                        ),
                                      ),
                                    );
                                    searchButtonPosition = -100;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)!
                                              .mapScreenSearchHere,
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              color: darkColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Icon(
                                          CupertinoIcons.arrow_right,
                                          color: darkColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      city != null
                                          ? "City: " + city!
                                          : "City: Unknown",
                                      maxLines: 2,
                                      overflow: TextOverflow.clip,
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: darkColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: CupertinoButton(
                                child: Text(
                                  'Refresh',
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                onPressed: _refresh),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  bottom: pinPillPosition,
                  right: 0,
                  left: 0,
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentPinInfo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CupertinoButton(
                                child: const Icon(
                                  CupertinoIcons.arrow_right_circle_fill,
                                  color: darkColor,
                                  size: 40,
                                ),
                                onPressed: () async {
                                  DocumentSnapshot updatedChosenPlace =
                                      await FirebaseFirestore.instance
                                          .collection("parking_places")
                                          .doc(pinId)
                                          .get();
                                  if (updatedChosenPlace.get('is_active')) {
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: PlaceInfoScreen(
                                          placeId: pinId!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Closed',
                                      body:
                                          'This parking place is closed for now',
                                    );
                                    showSimpleNotification(
                                      Text(notification.body),
                                      position: NotificationPosition.top,
                                      background: Colors.red,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PageReveal extends StatelessWidget {
  final double revealPercent;
  final Widget child;

  const PageReveal({Key? key, required this.revealPercent, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipper: CircleRevealClipper(revealPercent),
      child: child,
    );
  }
}

class CircleRevealClipper extends CustomClipper<Rect> {
  final double revealPercent;

  CircleRevealClipper(this.revealPercent);

  @override
  Rect getClip(Size size) {
    final epicenter = Offset(size.width / 2, size.height * 0.5);
    double theta = atan(epicenter.dy / epicenter.dx);
    final distanceToCorner = epicenter.dy / sin(theta);

    final radius = distanceToCorner * revealPercent;

    final diameter = 2 * radius;

    return Rect.fromLTWH(
        epicenter.dx - radius, epicenter.dy - radius, diameter, diameter);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
