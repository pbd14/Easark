import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Widgets/loading_screen.dart';
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                    space['isFree']
                                        ? 'assets/images/parking2.png'
                                        : 'assets/images/parking1.png',
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
          );
  }
}
