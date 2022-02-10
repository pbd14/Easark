import 'dart:async';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BookingScreen/components/space_info_screen.dart';
import 'package:easark/Screens/BookingScreen/components/space_info_type2_screen.dart';
import 'package:easark/Screens/BookingScreen/components/space_info_type3_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class PlaceInfoScreen extends StatefulWidget {
  String placeId;
  PlaceInfoScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceInfoScreen> createState() => _PlaceInfoScreenState();
}

class _PlaceInfoScreenState extends State<PlaceInfoScreen> {
  bool loading = true;
  bool infoExpansionPanel = false;
  DocumentSnapshot? place;
  double rating = 0;
  List spaces = [];
  List placeImages = [];

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get();

    setState(() {
      spaces = place!.get('spaces');
      placeImages = place!.get('images');
      loading = false;
      rating = place!.get('ratingsSum') / place!.get('ratingsNumber');
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
                        place!.get('name'),
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
                        place!.get('isppm')
                            ? place!.get('price').toString() +
                                ' ' +
                                place!.get('currency') +
                                ' per minute'
                            : place!.get('isFixedPrice')
                                ? place!.get('price').toString() +
                                    ' ' +
                                    place!.get('currency') +
                                    ' fixed price'
                                : 'Price',
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
                        place!.get('city'),
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
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: darkColor,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            rating.toStringAsFixed(1),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: darkColor,
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "#" + place!.id,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      CarouselSlider(
                        options: CarouselOptions(),
                        items: placeImages
                            .map((item) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: SizedBox(
                                        height: 200,
                                        width: size.width,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.none,
                                          height: 100,
                                          width: 100,
                                          placeholder: (context, url) =>
                                              SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Transform.scale(
                                              scale: 0.1,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 3.0,
                                                backgroundColor: darkColor,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(primaryColor),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.error,
                                            color: primaryColor,
                                          ),
                                          imageUrl: item,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
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
                              OpenContainer(
                                transitionDuration: const Duration(seconds: 1),
                                transitionType:
                                    ContainerTransitionType.fadeThrough,
                                openColor:
                                    const Color.fromRGBO(247, 247, 247, 1.0),
                                closedColor:
                                    const Color.fromRGBO(247, 247, 247, 1.0),
                                closedBuilder: (context, action) {
                                  return Column(
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
                                  );
                                },
                                tappable: space['isActive'],
                                openBuilder: (BuildContext context,
                                    void Function({Object? returnValue})
                                        action) {
                                  return place!.get('is24')
                                      ? SpaceInfoScreenType2(
                                          placeId: place!.id,
                                          spaceId: space['id'],
                                        )
                                      : SpaceInfoScreen(
                                          placeId: place!.id,
                                          spaceId: space['id'],
                                        );
                                },
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
