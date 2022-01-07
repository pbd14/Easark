import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointObject {
  final Widget child;
  final LatLng location;

  PointObject({required this.child, required this.location});
}
