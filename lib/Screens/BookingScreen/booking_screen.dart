import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class BookingsScreen extends StatefulWidget {
  String bookingId;
  BookingsScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _SpaceInfoScreenType2State();
}

class _SpaceInfoScreenType2State extends State<BookingsScreen> {
  bool loading = true;
  DocumentSnapshot? place;
  DocumentSnapshot? booking;
  Map space = {};

  Future<void> prepare() async {
    booking = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get();
    place = await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(booking!.get('place_id'))
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
    Size size = MediaQuery.of(context).size;
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.yMMMd()
                                .format(booking!.get('timestamp_date').toDate())
                                .toString(),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: darkDarkColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            booking!.get('from') + ' - ' + booking!.get('to'),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: darkDarkColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            place?.get('name') ?? 'Name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: darkDarkColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Parking lot #' +
                                booking!.get('space_id').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: darkDarkColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            // Booking.fromSnapshot(book)
                            //     .status,

                            booking!.get('status') == 'unfinished'
                                ? Languages.of(context)!.historyScreenUpcoming
                                : Languages.of(context)!
                                    .historyScreenVerificationNeeded,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: booking!.get('status') == 'unfinished'
                                    ? darkPrimaryColor
                                    : Colors.red,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: size.width * 0.3,
                        child: Column(
                          // crossAxisAlignment:
                          //     CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              iconSize: 30,
                              icon: const Icon(
                                CupertinoIcons.map_pin_ellipse,
                                color: darkPrimaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                // Navigator.push(
                                //   context,
                                //   SlideRightRoute(
                                //     page: MapPage(
                                //       isAppBar: true,
                                //       isLoading: true,
                                //       data: {
                                //         'lat': upcomingPlaces[
                                //                 Booking.fromSnapshot(
                                //                         book)
                                //                     .id]
                                //             .data()['lat'],
                                //         'lon': upcomingPlaces[
                                //                 Booking.fromSnapshot(
                                //                         book)
                                //                     .id]
                                //             .data()['lon']
                                //       },
                                //     ),
                                //   ),
                                // );
                                setState(() {
                                  loading = false;
                                });
                              },
                            ),
                            // IconButton(
                            //   icon: Icon(
                            //     CupertinoIcons.book,
                            //     color: darkPrimaryColor,
                            //   ),
                            //   onPressed: ()  {
                            //     setState(() {
                            //       loading = true;
                            //     });
                            //     Navigator.push(
                            //       context,
                            //       SlideRightRoute(
                            //         page: PlaceScreen(
                            //           data: {
                            //             'name':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .name, //0
                            //             'description': Place
                            //                     .fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                 .description, //1
                            //             'by':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .by, //2
                            //             'lat':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .lat, //3
                            //             'lon':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .lon, //4
                            //             'images':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .images, //5
                            //             'services':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .services,
                            //             'rates':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .rates,
                            //             'id':
                            //                 Place.fromSnapshot(
                            //                         _results[
                            //                             index])
                            //                     .id, //7
                            //           },
                            //         ),
                            //       ),
                            //     );
                            //     setState(() {
                            //       loading = false;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          );
  }
}
