import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class BookingManagementScreen extends StatefulWidget {
  String bookingId;
  BookingManagementScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
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
        : Scaffold(
          body: SingleChildScrollView(
              child: Container(
                color: const Color.fromRGBO(247, 247, 247, 1.0),
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    // Container(
                    //   width: size.width * 0.8,
                    //   child: Card(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20.0),
                    //     ),
                    //     elevation: 10,
                    //     margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    //     child: Padding(
                    //       padding: EdgeInsets.all(10.0),
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Text(
                    //                 place!.get('owner_phone'),
                    //                 overflow: TextOverflow.ellipsis,
                    //                 style: GoogleFonts.montserrat(
                    //                   textStyle: TextStyle(
                    //                     color: darkColor,
                    //                     fontSize: 20,
                    //                     fontWeight: FontWeight.bold,
                    //                   ),
                    //                 ),
                    //               ),
                    //               SizedBox(
                    //                 width: 20,
                    //               ),
                    //               CupertinoButton(
                    //                 padding: EdgeInsets.zero,
                    //                 onPressed: () async {
                    //                   await launch(
                    //                       "tel:" + place!.get('owner_phone'));
                    //                 },
                    //                 child: Container(
                    //                   height: 40,
                    //                   width: 40,
                    //                   decoration: BoxDecoration(
                    //                     shape: BoxShape.circle,
                    //                     color: primaryColor,
                    //                     boxShadow: [
                    //                       BoxShadow(
                    //                         color:
                    //                             darkPrimaryColor.withOpacity(0.5),
                    //                         spreadRadius: 5,
                    //                         blurRadius: 7,
                    //                         offset: Offset(0,
                    //                             3), // changes position of shadow
                    //                       ),
                    //                     ],
                    //                   ),
                    //                   child: Icon(
                    //                     CupertinoIcons.phone_fill,
                    //                     color: whiteColor,
                    //                     size: 20,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
        
                    Container(
                      width: size.width * 0.8,
                      child: Card(
                        elevation: 11,
                        margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.info_circle,
                                color: darkPrimaryColor,
                                size: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    booking!.get('status') == 'unfinished' ||
                                            booking!.get('status') ==
                                                'verification_needed'
                                        ? Text(
                                            'Event has not started yet',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
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
                                            'Event is going on',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
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
                                            'Client should pay. You can report if client has left without paying',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 10,
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: Colors.red,
                                                fontSize: 15,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: booking!.get('status') == 'unpaid'
                                          ? 10
                                          : 0,
                                    ),
                                    booking!.get('status') == 'unpaid'
                                        ? Center(
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
                                          )
                                        : Container(),
                                    booking!.get('status') == 'finished'
                                        ? Text(
                                            'Event has ended',
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
                                    booking!.get('status') == 'canceled'
                                        ? Text(
                                            'Event was canceled',
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
        
                    DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
                                booking!.get('deadline').seconds * 1000)) &&
                            booking!.get('status') != 'verification_needed' &&
                            booking!.get('status') != 'in process' &&
                            booking!.get('status') != 'unpaid' &&
                            booking!.get('status') != 'finished' &&
                            booking!.get('status') != 'canceled'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoButton(
                                onPressed: () {
                                  setState(() {
                                    showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Start?'),
                                          content: const Text(
                                              'Do you want to start the event?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  loading = true;
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('bookings')
                                                    .doc(booking!.id)
                                                    .update({
                                                  'status': 'in process',
                                                }).catchError((error) {
                                                  print('MISTAKE HERE');
                                                  print(error);
                                                  Navigator.of(context)
                                                      .pop(false);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Fail',
                                                    body: 'Failed to start',
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                        child: Text(
                                                            notification.body)),
                                                    position:
                                                        NotificationPosition.top,
                                                    background: Colors.red,
                                                  );
                                                });
        
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Started',
                                                  body: 'Event has started',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: greenColor,
                                                );
        
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'No',
                                                style:
                                                    TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      'Start',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
                                booking!.get('milliseconds_to'))) &&
                            booking!.get('status') != 'verification_needed' &&
                            booking!.get('status') != 'unfinished' &&
                            booking!.get('status') != 'unpaid' &&
                            booking!.get('status') != 'finished' &&
                            booking!.get('status') != 'canceled'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoButton(
                                onPressed: () {
                                  setState(() {
                                    showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Finish?'),
                                          content: const Text(
                                              'Do you want to finish the event?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  loading = true;
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('bookings')
                                                    .doc(booking!.id)
                                                    .update({
                                                  'status': 'unpaid',
                                                }).catchError((error) {
                                                  print('MISTAKE HERE');
                                                  print(error);
                                                  Navigator.of(context)
                                                      .pop(false);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Fail',
                                                    body: 'Failed to finish',
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                      child:
                                                          Text(notification.body),
                                                    ),
                                                    position:
                                                        NotificationPosition.top,
                                                    background: Colors.red,
                                                  );
                                                });
        
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Finished',
                                                  body: 'Event has ended',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: greenColor,
                                                );
        
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'No',
                                                style:
                                                    TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      'Finish',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: primaryColor, width: 3),
                                    shape: BoxShape.circle,
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
        
                    booking!.get('status') == 'unpaid'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoButton(
                                onPressed: () {
                                  setState(() {
                                    showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Sure?'),
                                          content: const Text(
                                              'Are you sure that client has made payment?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  loading = true;
                                                });
        
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'reported_bookings')
                                                    .doc(booking!.id)
                                                    .delete();
        
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(
                                                        booking!.get('client_id'))
                                                    .update({
                                                  'status': 'default',
                                                }).catchError((error) {
                                                  print('MISTAKE HERE');
                                                  print(error);
                                                  Navigator.of(context)
                                                      .pop(false);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Fail',
                                                    body: 'Failed',
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                        child: Text(
                                                            notification.body)),
                                                    position:
                                                        NotificationPosition.top,
                                                    background: Colors.red,
                                                  );
                                                });
        
                                                FirebaseFirestore.instance
                                                    .collection('bookings')
                                                    .doc(booking!.id)
                                                    .update({
                                                  'status': 'finished',
                                                  'isReported': false,
                                                }).catchError((error) {
                                                  print('MISTAKE HERE');
                                                  print(error);
                                                  Navigator.of(context)
                                                      .pop(false);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Fail',
                                                    body: 'Failed',
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                        child: Text(
                                                            notification.body)),
                                                    position:
                                                        NotificationPosition.top,
                                                    background: Colors.red,
                                                  );
                                                });
        
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Accepted',
                                                  body: 'Client has made payment',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: greenColor,
                                                );
        
                                                setState(() {
                                                  loading = false;
                                                });
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'No',
                                                style:
                                                    TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      'Paid',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: greenColor,
                                  ),
                                ),
                              ),
                              booking!.get('isReported') == null ||
                                      !booking!.get('isReported')
                                  ? SizedBox(width: 20)
                                  : Container(),
                              booking!.get('isReported') == null ||
                                      !booking!.get('isReported')
                                  ? CupertinoButton(
                                      onPressed: () {
                                        setState(() {
                                          showDialog(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Report?'),
                                                content: const Text(
                                                    'Do you want to report that client has not paid?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          updatedBooking =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'bookings')
                                                              .doc(booking!.id)
                                                              .get();
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'reported_bookings')
                                                          .doc(booking!.id)
                                                          .set(updatedBooking
                                                              .data()!)
                                                          .catchError((error) {
                                                        print('MISTAKE HERE');
                                                        print(error);
                                                        Navigator.of(context)
                                                            .pop(false);
                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Fail',
                                                          body: 'Failed',
                                                        );
                                                        showSimpleNotification(
                                                          Container(
                                                              child: Text(
                                                                  notification
                                                                      .body)),
                                                          position:
                                                              NotificationPosition
                                                                  .top,
                                                          background: Colors.red,
                                                        );
                                                      });
        
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(booking!.get('client_id'))
                                                          .update({
                                                        'status': 'blocked'
                                                      }).catchError((error) {
                                                        print('MISTAKE HERE');
                                                        print(error);
                                                        Navigator.of(context)
                                                            .pop(false);
                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Fail',
                                                          body: 'Failed',
                                                        );
                                                        showSimpleNotification(
                                                          Container(
                                                              child: Text(
                                                                  notification
                                                                      .body)),
                                                          position:
                                                              NotificationPosition
                                                                  .top,
                                                          background: Colors.red,
                                                        );
                                                      });
        
                                                      FirebaseFirestore.instance
                                                          .collection('bookings')
                                                          .doc(booking!.id)
                                                          .update({
                                                        'isReported': true
                                                      }).catchError((error) {
                                                        print('MISTAKE HERE');
                                                        print(error);
                                                        Navigator.of(context)
                                                            .pop(false);
                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Fail',
                                                          body: 'Failed',
                                                        );
                                                        showSimpleNotification(
                                                          Container(
                                                              child: Text(
                                                                  notification
                                                                      .body)),
                                                          position:
                                                              NotificationPosition
                                                                  .top,
                                                          background: Colors.red,
                                                        );
                                                      });
        
                                                      PushNotificationMessage
                                                          notification =
                                                          PushNotificationMessage(
                                                        title: 'Reported',
                                                        body:
                                                            'Client was reported',
                                                      );
                                                      showSimpleNotification(
                                                        Container(
                                                            child: Text(
                                                                notification
                                                                    .body)),
                                                        position:
                                                            NotificationPosition
                                                                .top,
                                                        background: greenColor,
                                                      );
        
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          color: primaryColor),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        child: Center(
                                          child: Text(
                                            'Report',
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: whiteColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 40,
                    ),
                    Center(
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
                                    .format(
                                        booking!.get('timestamp_from').toDate())
                                    .toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: whiteColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                Languages.of(context)!.serviceScreenFrom +
                                    '\n' +
                                    DateFormat.yMMMd()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                booking!
                                                    .get('timestamp_from')
                                                    .millisecondsSinceEpoch))
                                        .toString() +
                                    ' ' +
                                    DateFormat.Hm()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                booking!
                                                    .get('timestamp_from')
                                                    .millisecondsSinceEpoch))
                                        .toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: whiteColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                Languages.of(context)!.serviceScreenTo +
                                    '\n' +
                                    DateFormat.yMMMd()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                booking!
                                                    .get('timestamp_to')
                                                    .millisecondsSinceEpoch))
                                        .toString() +
                                    ' ' +
                                    DateFormat.Hm()
                                        .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                booking!
                                                    .get('timestamp_to')
                                                    .millisecondsSinceEpoch))
                                        .toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: whiteColor,
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
                              booking!.get('status') == 'unfinished' ||
                                      booking!.get('status') ==
                                          'verification_needed'
                                  ? Text(
                                      Languages.of(context)!.oeScreenNotStarted,
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
                                      Languages.of(context)!.oeScreenInProcess,
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
                                      Languages.of(context)!.oeScreenMakePayment,
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
                                      booking!.get('payment_method') == 'card'
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
                                    booking!.get('status') == 'unpaid' ? 10 : 0,
                              ),
                              booking!.get('status') == 'unpaid'
                                  ? Center(
                                      child: Text(
                                        booking!.get('price').toString() +
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
                                    )
                                  : Container(),
                              booking!.get('status') == 'finished'
                                  ? Text(
                                      Languages.of(context)!.oeScreenEnded,
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
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: size.width * 0.3,
                            child: Column(
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
              ),
            ),
        );
  }
}
