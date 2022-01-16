import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BusinessScreen/business_screen.dart';
import 'package:easark/Widgets/loading_map_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class AddPlaceScreen2 extends StatefulWidget {
  Map data;
  AddPlaceScreen2({Key? key, required this.data}) : super(key: key);
  @override
  _AddPlaceScreen2State createState() => _AddPlaceScreen2State();
}

class _AddPlaceScreen2State extends State<AddPlaceScreen2> {
  bool loading = false;
  bool loading1 = true;
  static LatLng _initialPosition =
      const LatLng(41.36426966573496, 69.21005744487047);
  final Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController? _mapController;
  double? lat, lon;
  // ignore: avoid_init_to_null

  @override
  void initState() {
    _getPermission();
    _getUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _updatePosition(CameraPosition _position) {
    Position newMarkerPosition = Position(
        heading: 0,
        altitude: 0,
        timestamp: DateTime.now(),
        speedAccuracy: 0,
        speed: 0,
        accuracy: 0,
        latitude: _position.target.latitude,
        longitude: _position.target.longitude);
    Marker marker = _markers.first;

    setState(() {
      lat = newMarkerPosition.latitude;
      lon = newMarkerPosition.longitude;
      _markers.remove(marker);
      _markers.add(marker.copyWith(
          positionParam:
              LatLng(newMarkerPosition.latitude, newMarkerPosition.longitude)));
    });
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
        loading1 = false;
      });
    }
  }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    _mapController?.setMapStyle(style);
    _markers.add(
      const Marker(
        draggable: true,
        markerId: MarkerId('Marker'),
        position: LatLng(41.3209472793112, 69.24170952290297),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      loading = false;
    });
    _setMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Location',
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    color: whiteColor,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                loading1
                    ? const LoadingMapScreen()
                    : GoogleMap(
                        mapType: MapType.normal,
                        minMaxZoomPreference:
                            const MinMaxZoomPreference(10.0, 40.0),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapToolbarEnabled: true,
                        onMapCreated: _onMapCreated,
                        onCameraMove: ((_position) =>
                            _updatePosition(_position)),
                        // initialCameraPosition: CameraPosition(
                        //   target: LatLng(41.3174, 69.2483),
                        //   zoom: 11,
                        // ),
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 15,
                        ),
                        markers: _markers,
                      ),
                Positioned(
                  bottom: 70,
                  right: size.width * 0.15,
                  child: RoundedButton(
                    width: 0.7,
                    ph: 55,
                    text: 'CONTINUE',
                    press: () async {
                      setState(() {
                        loading = true;
                      });
                      List<Map> spaces = [];
                      for (int i = 1;
                          i <= widget.data['number_of_spaces'];
                          i++) {
                        spaces.add({
                          'id': i,
                          'isFree': true,
                          'isActive': true,
                        });
                      }
                      String id =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      FirebaseFirestore.instance
                          .collection('parking_places')
                          .doc(id)
                          .set({
                        'id': id,
                        'number_of_spaces': widget.data['number_of_spaces'],
                        'description': widget.data['description'],
                        'country': widget.data['country'],
                        'state': widget.data['state'],
                        'city': widget.data['city'],
                        'needs_verification': widget.data['needs_verification'],
                        'currency': widget.data['currency'],
                        'ppm': widget.data['ppm'],
                        'is24': widget.data['is24'],
                        'payment_methods': widget.data['payment_methods'],
                        'days': widget.data['days'],
                        'vacation_days': widget.data['vacation_days'],
                        'lat': lat,
                        'lon': lon,
                        'images': widget.data['images'],
                        'spaces': spaces,
                        'rates': {},
                        'owner_id': widget.data['owner_id'],
                        'is_blocked': false,
                      }).catchError((error) {
                        PushNotificationMessage notification =
                            PushNotificationMessage(
                          title: 'Fail',
                          body: 'Failed to create',
                        );
                        showSimpleNotification(
                          Container(child: Text(notification.body)),
                          position: NotificationPosition.top,
                          background: Colors.red,
                        );
                      });
                      PushNotificationMessage notification =
                          PushNotificationMessage(
                        title: 'Success',
                        body: 'Added new place',
                      );
                      showSimpleNotification(
                        Container(child: Text(notification.body)),
                        position: NotificationPosition.top,
                        background: greenColor,
                      );
                      Navigator.push(
                        context,
                        SlideRightRoute(page: const BusinessScreen()),
                      );

                      setState(() {
                        loading = false;
                        lat = null;
                        lon = null;
                      });
                    },
                    color: darkPrimaryColor,
                    textColor: whiteColor,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
