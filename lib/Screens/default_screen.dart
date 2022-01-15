import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DefaultScreen extends StatefulWidget {
  String error;
  DefaultScreen({Key? key, this.error = 'Something Went Wrong'})
      : super(key: key);

  @override
  State<DefaultScreen> createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Default Screen'),
      ),
    );
  }
}
