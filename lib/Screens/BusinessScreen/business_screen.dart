import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/components/introduction.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({Key? key}) : super(key: key);
  @override
  _BusinessScreenScreenState createState() => _BusinessScreenScreenState();
}

class _BusinessScreenScreenState extends State<BusinessScreen> {
  bool loading = true;

  void prepare() async {
    QuerySnapshot places = await FirebaseFirestore.instance
        .collection('parking_places')
        .where('owner_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (places.docs.isEmpty) {
      Navigator.push(
        context,
        SlideRightRoute(
          page: const IntroductionScreen(),
        ),
      );
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingScreen()
        : Scaffold(
            body: Container(),
          );
  }
}
