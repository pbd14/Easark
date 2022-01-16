import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/components/edit_place.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class PlaceScreen extends StatefulWidget {
  String placeId;
  PlaceScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  bool loading = true;
  bool infoExpansionPanel = false;
  DocumentSnapshot? place;
  List spaces = [];

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get();

    setState(() {
      spaces = place!.get('spaces');
      loading = false;
    });
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    spaces = [];
    prepare();
    Completer<void> completer = Completer<void>();
    completer.complete();
    return completer.future;
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
        : RefreshIndicator(
            onRefresh: _refresh,
            color: darkColor,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: const Color.fromRGBO(247, 247, 247, 1.0),
                iconTheme: const IconThemeData(
                  color: darkDarkColor,
                ),
                title: Text(
                  'Parking Spaces',
                  textScaleFactor: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                        color: darkColor,
                        fontSize: 23,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                centerTitle: true,
              ),
              backgroundColor: const Color.fromRGBO(247, 247, 247, 1.0),
              body: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      size.width * 0.05, 20, size.width * 0.05, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "#" + place!.id,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        place!.get('city'),
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RoundedButton(
                            pw: 100,
                            ph: 45,
                            text: 'EDIT',
                            press: () async {
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: EditPlaceScreen(
                                    placeId: place!.id,
                                  ),
                                ),
                              );
                            },
                            color: lightPrimaryColor,
                            textColor: whiteColor,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          RoundedButton(
                            pw: 100,
                            ph: 45,
                            text: 'DELETE',
                            press: () async {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete?'),
                                    content: const Text(
                                        'Are your sure you want to delete this parking place?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // prefs.setBool('local_auth', false);
                                          // prefs.setString('local_password', '');
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text(
                                          'No',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            color: Colors.red,
                            textColor: whiteColor,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ExpansionPanelList(
                        elevation: 0,
                        expansionCallback: (i, isOpen) {
                          setState(() {
                            infoExpansionPanel = !infoExpansionPanel;
                          });
                        },
                        children: [
                          ExpansionPanel(
                            isExpanded: infoExpansionPanel,
                            backgroundColor:
                                const Color.fromRGBO(247, 247, 247, 1.0),
                            canTapOnHeader: true,
                            headerBuilder: (context, isOpen) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                  child: Text(
                                    'Info',
                                    maxLines: 1000,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              );
                            },
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  maxLines: 1000,
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    place!.get('description'),
                                    maxLines: 1000,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RoundedButton(
                        width: 0.4,
                        ph: 45,
                        text: 'ADD SPACE',
                        press: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Sure?'),
                                content: const Text(
                                    'Do you want to add a parking space?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      // prefs.setBool('local_auth', false);
                                      // prefs.setString('local_password', '');
                                      Navigator.of(context).pop(true);
                                      FirebaseFirestore.instance
                                          .collection('parking_places')
                                          .doc(place!.id)
                                          .update({
                                        'number_of_places':
                                            place!.get('number_of_places') + 1,
                                        'spaces': FieldValue.arrayUnion(
                                          [
                                            {
                                              'id': spaces.length + 1,
                                              'isActive': true,
                                              'isFree': true,
                                            },
                                          ],
                                        )
                                      });
                                      _refresh();
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(
                                      'No',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        color: darkPrimaryColor,
                        textColor: whiteColor,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Flexible(
                        child: GridView.count(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          // scrollDirection: Axis,
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (Map space in spaces)
                              Column(
                                children: [
                                  Text(
                                    '#' + space['id'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // const SizedBox(
                                  //   height: 5,
                                  // ),
                                  Expanded(
                                    child: Image.asset(
                                      !space['isFree']
                                          ? 'assets/images/parking1.png'
                                          : space['isActive']
                                              ? 'assets/images/parking2.png'
                                              : 'assets/images/parking3.png',
                                      width: 75,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
