import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:easark/Screens/ProfileScreen/profile_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/point_object.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  String error;
  MapScreen({Key? key, this.error = 'Something Went Wrong'}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double pinPillPosition = -100;
  bool loading = false;
  final Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController? _mapController;
  // ignore: avoid_init_to_null
  static LatLng _initialPosition =
      const LatLng(41.36426966573496, 69.21005744487047);
  BitmapDescriptor? pinLocationIcon;
  String currentPinInfo = 'Loading ...';

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getUserLocation();
    prepare();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _getPermission() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _getUserLocation() async {
    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

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
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('parking_places').get();
    final places = data.docs;
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 3),
      'assets/icons/marker.png',
    );

    setState(() {
      for (QueryDocumentSnapshot place in places) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.get('lat'), place.get('lon')),
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
                currentPinInfo = place.get('ppm').toString() + ' ' + place.get('currency');
                pinPillPosition = 100;
              });
            },
            icon: pinLocationIcon!,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const LoadingScreen()
          : Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  minMaxZoomPreference: const MinMaxZoomPreference(5.0, 40.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onTap: (LatLng location) {
                    setState(() {
                      currentPinInfo = 'Loading ...';
                      pinPillPosition = -100;
                    });
                  },
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: ProfileScreen(),
                                    ),
                                  );
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
