import 'dart:async';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BusinessScreen/components/edit_place.dart';
import 'package:easark/Screens/BusinessScreen/components/space_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

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
  bool isActive = true;
  double rating = 0;
  DocumentSnapshot? place;
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
      isActive = place!.get('is_active');
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
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
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundedButton(
                              pw: 120,
                              ph: 45,
                              text: isActive ? 'CLOSE' : 'OPEN',
                              press: () async {
                                setState(() {
                                  loading = true;
                                  isActive = !isActive;
                                });
                                FirebaseFirestore.instance
                                    .collection('parking_places')
                                    .doc(widget.placeId)
                                    .update({
                                  'is_active': isActive,
                                }).catchError((error) {
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Fail',
                                    body: 'Failed to update',
                                  );
                                  showSimpleNotification(
                                    Text(notification.body),
                                    position: NotificationPosition.top,
                                    background: Colors.red,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      isActive = !isActive;
                                      loading = false;
                                    });
                                  } else {
                                    isActive = !isActive;
                                    loading = false;
                                  }
                                });
                                if (mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  loading = false;
                                }
                              },
                              color: !isActive ? greenColor : darkDarkColor,
                              textColor: !isActive ? darkDarkColor : greenColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                isActive
                                    ? ' Current state: OPEN'
                                    : ' Current state: CLOSE',
                                maxLines: 1000,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
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
                      Center(
                        child: RoundedButton(
                          width: 0.4,
                          ph: 45,
                          text: 'ADD SPACE',
                          press: () {
                            if (spaces.length < 1000) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
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
                                            'number_of_spaces':
                                                place!.get('number_of_spaces') +
                                                    1,
                                            'spaces': FieldValue.arrayUnion(
                                              [
                                                {
                                                  'id': spaces.last['id'] + 1,
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
                            }
                          },
                          color: darkPrimaryColor,
                          textColor: whiteColor,
                        ),
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
                                openBuilder: (BuildContext context,
                                    void Function({Object? returnValue})
                                        action) {
                                  return SpaceScreen(
                                      placeId: widget.placeId,
                                      spaceId: space['id']);
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
