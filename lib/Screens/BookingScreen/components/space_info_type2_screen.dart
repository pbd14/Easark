import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class SpaceInfoScreenType2 extends StatefulWidget {
  String placeId;
  int spaceId;
  SpaceInfoScreenType2({Key? key, required this.placeId, required this.spaceId})
      : super(key: key);

  @override
  State<SpaceInfoScreenType2> createState() => _SpaceInfoScreenType2State();
}

class _SpaceInfoScreenType2State extends State<SpaceInfoScreenType2> {
  bool loading = true;
  DocumentSnapshot? place;
  Map space = {};

  Future<void> prepare() async {
    await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get()
        .then((value) {
      setState(() {
        place = value;
        loading = false;
        space = value.get('spaces').where((element) => element['id'] == widget.spaceId).first;
      });
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
        : Container(
            color: const Color.fromRGBO(247, 247, 247, 1.0),
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Image.asset(
                      !space['isFree']
                          ? 'assets/images/parking1.png'
                          : space['isActive']
                              ? 'assets/images/parking2.png'
                              : 'assets/images/parking3.png',
                      width: 100,
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "#" + widget.spaceId.toString() + ' parking lot',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          color: darkPrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          );
  }
}
