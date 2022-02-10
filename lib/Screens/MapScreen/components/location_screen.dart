import 'dart:collection';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class LocationScreen extends StatefulWidget {
  Map data;
  LocationScreen({required this.data});
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController? _mapController;
  // ignore: avoid_init_to_null

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController!.dispose();
    super.dispose();
  }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    _mapController!.setMapStyle(style);
    _markers.add(Marker(
      markerId: MarkerId('0'),
      position: LatLng(widget.data['lat'], widget.data['lon']),
    ));
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
      ),
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.data['lat'], widget.data['lon']),
              zoom: 15,
            ),
            markers: _markers,
          ),
          loading
              ? Positioned.fill(
                  child: Center(
                    child: LoadingScreen(),
                  ),
                )
              : Container()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
