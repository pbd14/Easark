import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class BookingScreen extends StatefulWidget {
  String bookingId;
  BookingScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool loading = true;
  DocumentSnapshot? place;
  DocumentSnapshot? booking;
  StreamSubscription<DocumentSnapshot>? bookingSubscr;
  Map space = {};

  Future<void> prepare() async {
    bookingSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((thisBooking) async {
      place = await FirebaseFirestore.instance
          .collection('parking_places')
          .doc(thisBooking.get('place_id'))
          .get();
      if (this.mounted) {
        setState(() {
          booking = thisBooking;
          loading = false;
        });
      } else {
        booking = thisBooking;
        loading = false;
      }
    });

    setState(() {
      loading = false;
    });
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    bookingSubscr!.cancel();
    space = {};
    prepare();

    Completer<void> completer = Completer<void>();
    completer.complete();
    return completer.future;
  }

  @override
  void dispose() {
    bookingSubscr!.cancel();
    super.dispose();
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
                'Booking',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                      color: darkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              color: darkColor,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Container(
                  // color: const Color.fromRGBO(247, 247, 247, 1.0),
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        // padding: EdgeInsets.all(10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.all(5),
                          elevation: 10,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(booking!
                                                  .get('timestamp_from')
                                                  .toDate())
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
                                          Languages.of(context)!
                                                  .serviceScreenFrom +
                                              '\n' +
                                              DateFormat.yMMMd()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          booking!
                                                              .get(
                                                                  'timestamp_from')
                                                              .millisecondsSinceEpoch))
                                                  .toString() +
                                              ' ' +
                                              DateFormat.Hm()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          booking!
                                                              .get(
                                                                  'timestamp_from')
                                                              .millisecondsSinceEpoch))
                                                  .toString(),
                                          maxLines: 3,
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
                                          Languages.of(context)!
                                                  .serviceScreenTo +
                                              '\n' +
                                              DateFormat.yMMMd()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          booking!
                                                              .get(
                                                                  'timestamp_to')
                                                              .millisecondsSinceEpoch))
                                                  .toString() +
                                              ' ' +
                                              DateFormat.Hm()
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          booking!
                                                              .get(
                                                                  'timestamp_to')
                                                              .millisecondsSinceEpoch))
                                                  .toString(),
                                          maxLines: 3,
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
                                              booking!
                                                  .get('space_id')
                                                  .toString(),
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
                                          booking!.get('status') == 'unfinished'
                                              ? Languages.of(context)!
                                                  .historyScreenUpcoming
                                              : Languages.of(context)!
                                                  .historyScreenVerificationNeeded,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: booking!.get('status') ==
                                                      'unfinished'
                                                  ? darkPrimaryColor
                                                  : Colors.red,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        booking!.get('status') ==
                                                    'unfinished' ||
                                                booking!.get('status') ==
                                                    'verification_needed'
                                            ? Text(
                                                Languages.of(context)!
                                                    .oeScreenNotStarted,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        booking!.get('status') == 'in process'
                                            ? Text(
                                                Languages.of(context)!
                                                    .oeScreenInProcess,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: greenColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        booking!.get('status') == 'unpaid'
                                            ? Text(
                                                Languages.of(context)!
                                                    .oeScreenMakePayment,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 10,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        booking!.get('status') == 'unpaid' &&
                                                booking!.get(
                                                        'payment_method') ==
                                                    'card'
                                            ? Text(
                                                Languages.of(context)!
                                                        .oeScreenMakePaymentWith +
                                                    " " +
                                                    Languages.of(context)!
                                                        .serviceScreenCreditCard,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 8,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height:
                                              booking!.get('status') == 'unpaid'
                                                  ? 10
                                                  : 0,
                                        ),
                                        booking!.get('status') == 'unpaid'
                                            ? Center(
                                                child: Text(
                                                  booking!
                                                          .get('price')
                                                          .toString() +
                                                      booking!.get('currency'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 15,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkColor,
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        booking!.get('status') == 'finished'
                                            ? Text(
                                                Languages.of(context)!
                                                    .oeScreenEnded,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            booking!.get('price').toString() +
                                                ' ' +
                                                booking!.get('currency'),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 15,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        width: size.width * 0.8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      place!.get('owner_phone'),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        await launch(
                                            "tel:" + place!.get('owner_phone'));
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: darkPrimaryColor
                                                  .withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          CupertinoIcons.phone_fill,
                                          color: whiteColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
