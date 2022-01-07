import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  String error;
  MapScreen({Key? key, this.error = 'Something Went Wrong'}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Map Screen'),),
    );
  }
}
