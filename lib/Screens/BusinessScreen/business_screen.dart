import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/components/add_place1.dart';
import 'package:easark/Screens/BusinessScreen/components/introduction.dart';
import 'package:easark/Screens/BusinessScreen/components/place_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({Key? key}) : super(key: key);
  @override
  _BusinessScreenScreenState createState() => _BusinessScreenScreenState();
}

class _BusinessScreenScreenState extends State<BusinessScreen> {
  bool loading = true;
  QuerySnapshot? places;

  Future<void> prepare() async {
    places = await FirebaseFirestore.instance
        .collection('parking_places')
        .where('owner_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        // .orderBy('id', descending: true)
        .get();
    if (places!.docs.isEmpty) {
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
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Center(
                    child: Text(
                      'Your parking places',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                for (QueryDocumentSnapshot place in places!.docs)
                  CupertinoButton(
                    onPressed: () {
                      if (!place.get('is_blocked')) {
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page: PlaceScreen(
                              placeId: place.id,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      width: size.width * 0.9,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.get('name'),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                place.get('number_of_spaces').toString() +
                                    ' parking spaces',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "#" + place.id,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                place.get('city'),
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  width: 0.4,
                  ph: 45,
                  text: 'ADD PLACE',
                  press: () async {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: const AddPlaceScreen(),
                      ),
                    );
                  },
                  color: darkPrimaryColor,
                  textColor: whiteColor,
                ),
                SizedBox(
                  height: size.height * 0.2,
                ),
              ],
            ),
          ));
  }
}
