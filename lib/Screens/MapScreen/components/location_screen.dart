import 'dart:collection';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
          AnimatedPositioned(
            top: 10,
            right: 0,
            left: 0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: CupertinoButton(
                    child: Text(
                      'Share',
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
                    onPressed: () {
                      Share.share('https://www.google.com/maps/search/?api=1&query=${widget.data['lat']},${widget.data['lon']}');
                      // launchUrl(
                      //   Uri(
                      //     scheme: "https",
                      //     path: 'www.google.com/maps/search/?api=1&query=${widget.data['lat']},${widget.data['lon']}',
                      //     // path: 'www.google.com/maps/search/?api=1&query=27.985694,-82.4923699',
                      //     // path: "www.google.com/maps/@27.985694,-82.4923699,15z"
                          
                      //   ),
                      //   mode: LaunchMode.platformDefault
                      // );
                    }),
              ),
            ),
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
