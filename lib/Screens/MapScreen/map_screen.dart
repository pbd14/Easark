import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:easark/Screens/ProfileScreen/profile_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:easark/Widgets/ciw.dart';
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
  StreamSubscription? _mapIdleSubscription;
  InfoWidgetRoute? _infoWidgetRoute;
  bool loading = false;
  final Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController? _mapController;
  // ignore: avoid_init_to_null
  static LatLng _initialPosition = const LatLng(41, 60);
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

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
    _customInfoWindowController.dispose();
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      loading = false;
    });
  }

  void prepare() async {
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('parking_places').get();
    final places = data.docs;

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
                // _customInfoWindowController.addInfoWindow!(
                //   // ignore: avoid_unnecessary_containers
                //   Container(
                //     height: 30,
                //     child: Card(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20.0),
                //       ),
                //       elevation: 10,
                //       child: Padding(
                //         padding: const EdgeInsets.all(20),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(
                //               place.get('ppm').toString() +
                //                   place.get('currency').toString(),
                //               maxLines: 2,
                //               overflow: TextOverflow.ellipsis,
                //               style: GoogleFonts.montserrat(
                //                 textStyle: const TextStyle(
                //                   color: darkColor,
                //                   fontSize: 28,
                //                   fontWeight: FontWeight.w600,
                //                 ),
                //               ),
                //             ),
                //             const SizedBox(
                //               width: 10,
                //             ),
                //             CupertinoButton(
                //                 child: const Icon(
                //                   CupertinoIcons.info_circle,
                //                   color: darkColor,
                //                 ),
                //                 onPressed: () {
                //                   Navigator.push(
                //                     context,
                //                     SlideRightRoute(
                //                       page: ProfileScreen(),
                //                     ),
                //                   );
                //                 }),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   LatLng(
                //     place.get('lat') - 0.0001,
                //     place.get('lon'),
                //   ),
                // );
              },
              infoWindow: InfoWindow(
                  title: place.get('ppm').toString() + place.get('currency'))),
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
                  minMaxZoomPreference: const MinMaxZoomPreference(10.0, 40.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onCameraMove: (newPosition) {
                    _mapIdleSubscription?.cancel();
                    _mapIdleSubscription =
                        Future.delayed(const Duration(milliseconds: 150))
                            .asStream()
                            .listen((_) {
                      if (_infoWidgetRoute != null) {
                        Navigator.of(context, rootNavigator: true)
                            .push(_infoWidgetRoute!)
                            .then<void>(
                          (newValue) {
                            _infoWidgetRoute = null;
                          },
                        );
                      }
                    });
                  },
                ),
                // CustomInfoWindow(
                //   controller: _customInfoWindowController,
                //   height: 75,
                //   width: 150,
                //   offset: 50,
                // ),
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
