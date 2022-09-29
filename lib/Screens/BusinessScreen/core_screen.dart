import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/business_schedule_screen.dart';
import 'package:easark/Screens/BusinessScreen/business_screen.dart';
import 'package:easark/Screens/BusinessScreen/components/introduction.dart';
import 'package:easark/Screens/HistoryScreen/components/1.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoreScreen extends StatefulWidget {
  @override
  _CoreScreenState createState() => _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  String? stext;
  bool loading = true;
  QuerySnapshot? places;

  Future<void> prepare() async {
    places = await FirebaseFirestore.instance
        .collection('parking_places')
        .where('owner_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        // .orderBy('id', descending: true)
        .get();
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
    // Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : places!.docs.isEmpty
            ? IntroductionScreen()
            : DefaultTabController(
                length: 2,
                child: Scaffold(
                  backgroundColor: whiteColor,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 60,
                    backgroundColor: darkColor,
                    centerTitle: true,
                    title: TabBar(
                      indicatorColor: primaryColor,
                      tabs: [
                        Tab(
                          child: Text(
                            Languages.of(context)!.historyScreenSchedule,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Places',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      BusinessSchedule(),
                      BusinessScreen(),
                    ],
                  ),
                ),
              );
  }
}
