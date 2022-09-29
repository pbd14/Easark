import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:easark/Services/messaging_service.dart';

// ignore: must_be_immutable
class SpaceInfoScreen extends StatefulWidget {
  String placeId;
  int spaceId;
  SpaceInfoScreen({Key? key, required this.placeId, required this.spaceId})
      : super(key: key);

  @override
  State<SpaceInfoScreen> createState() => _SpaceInfoScreenState();
}

class _SpaceInfoScreenState extends State<SpaceInfoScreen> {
  bool loading = true;
  DocumentSnapshot? place;
  Map space = {};

  List<QueryDocumentSnapshot> alreadyBookings = [];

  double? _height;
  double? _width;
  double duration = 0;
  double price = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  bool can = true;
  bool isConnected = false;
  bool isDate1 = false;
  bool isDate2 = false;
  bool isTime1 = false;
  bool isTime2 = false;

  String? error;
  String? fromTimeString;
  String? _dow;
  String payment_way = '';

  DateTime? timestamp_from;
  DateTime? timestamp_to;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = const TimeOfDay(hour: 00, minute: 00);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _timeController2 = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _timeController2.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    if (timestamp_from!.isBefore(DateTime.now())) {
      if (timestamp_from!.day != DateTime.now().day) {
        setState(() {
          error = Languages.of(context)!.serviceScreenIncorrectDate;
          loading1 = false;
          verified = false;
        });
        return;
      } else {
        setState(() {
          error = Languages.of(context)!.serviceScreenIncorrectTime;
          loading1 = false;
          verified = false;
        });
        return;
      }
    }

    if (place!.get('needs_verification')) {
      if (timestamp_from!.day == DateTime.now().day &&
          timestamp_from!.month == DateTime.now().month &&
          timestamp_from!.year == DateTime.now().year) {
        if ((timestamp_from!.minute + timestamp_from!.hour * 60) -
                (DateTime.now().minute + DateTime.now().hour * 60) <
            120) {
          setState(() {
            error = Languages.of(context)!.serviceScreen2HoursAdvance;
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (timestamp_from!.isAfter(timestamp_to!)) {
      setState(() {
        error = Languages.of(context)!.serviceScreenIncorrectTime;
        loading1 = false;
        verified = false;
      });
      return;
    } else {
      if (place!.get('vacation_days') != null &&
          place!.get('vacation_days').contains(selectedDate.toString())) {
        setState(() {
          error = 'This place is closed this day';
          loading1 = false;
          verified = false;
        });
      } else {
        if (place!.get('days')[_dow]['status'] == 'closed') {
          setState(() {
            error = 'This place is closed this day';
            loading1 = false;
            verified = false;
          });
        } else {
          TimeOfDay placeTo = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(place!.get('days')[_dow]['to']));
          TimeOfDay placeFrom = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(place!.get('days')[_dow]['from']));
          double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
          double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;

          double dTimeFrom = timestamp_from!.hour.toDouble() * 60 +
              timestamp_from!.minute.toDouble();
          double dTimeTo = timestamp_to!.hour.toDouble() * 60 +
              timestamp_to!.minute.toDouble();
          if (dTimeFrom < dplaceFrom || dTimeTo < dplaceFrom) {
            setState(() {
              error = Languages.of(context)!.serviceScreenTooEarly;
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dTimeFrom > dplaceTo || dTimeTo > dplaceTo) {
            setState(() {
              error = Languages.of(context)!.serviceScreenTooLate;
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dTimeFrom >= dplaceFrom && dTimeTo <= dplaceTo) {
            QuerySnapshot alreadyBookings1 = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'place_id',
                  isEqualTo: widget.placeId,
                )
                .where(
                  'space_id',
                  isEqualTo: widget.spaceId,
                )
                .where('milliseconds_from',
                    isGreaterThanOrEqualTo:
                        timestamp_from!.millisecondsSinceEpoch)
                .where('milliseconds_from',
                    isLessThan: timestamp_to!.millisecondsSinceEpoch)
                .get();
            if (alreadyBookings1.docs.isNotEmpty) {
              setState(() {
                error = 'This time is already booked';
                loading1 = false;
                verified = false;
              });
              return;
            }
            QuerySnapshot alreadyBookings2 = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'place_id',
                  isEqualTo: widget.placeId,
                )
                .where(
                  'space_id',
                  isEqualTo: widget.spaceId,
                )
                .where('milliseconds_to',
                    isGreaterThan: timestamp_from!.millisecondsSinceEpoch)
                .where('milliseconds_to',
                    isLessThanOrEqualTo: timestamp_to!.millisecondsSinceEpoch)
                .get();
            if (alreadyBookings2.docs.isNotEmpty) {
              setState(() {
                error = 'This time is already booked';
                loading1 = false;
                verified = false;
              });
              return;
            }
            QuerySnapshot alreadyBookings3 = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'place_id',
                  isEqualTo: widget.placeId,
                )
                .where(
                  'space_id',
                  isEqualTo: widget.spaceId,
                )
                .where('milliseconds_to',
                    isGreaterThanOrEqualTo:
                        timestamp_to!.millisecondsSinceEpoch)
                .get();
            if (alreadyBookings3.docs.isNotEmpty) {
              for (QueryDocumentSnapshot book in alreadyBookings3.docs) {
                if (book.get('milliseconds_from') <=
                    timestamp_from!.millisecondsSinceEpoch) {
                  setState(() {
                    error = 'This time is already booked';
                    loading1 = false;
                    verified = false;
                  });
                  return;
                }
              }
            }

            setState(() {
              duration = timestamp_to!
                  .difference(timestamp_from!)
                  .inMinutes
                  .toDouble();
              if (place!.get('isppm')) {
                price = duration * place!.get('price');
              } else if (place!.get('isFixedPrice')) {
                price = place!.get('price');
              }
              loading1 = false;
              verified = true;
            });
          }
        }
      }
    }
  }

  Future<void> bookButton() async {
    if (timestamp_from!.isBefore(DateTime.now())) {
      setState(() {
        can = false;
      });
      return;
    }

    if (timestamp_from!.isAfter(timestamp_to!)) {
      setState(() {
        can = false;
      });
      return;
    } else {
      if (place!.get('days')[_dow]['status'] == 'closed') {
        setState(() {
          can = false;
        });
        return;
      } else {
        TimeOfDay placeTo = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(place!.get('days')[_dow]['to']));
        TimeOfDay placeFrom = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(place!.get('days')[_dow]['from']));
        double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
        double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;

        double dTimeFrom = timestamp_from!.hour.toDouble() * 60 +
            timestamp_from!.minute.toDouble();
        double dTimeTo = timestamp_to!.hour.toDouble() * 60 +
            timestamp_to!.minute.toDouble();
        if (dTimeFrom < dplaceFrom || dTimeTo < dplaceFrom) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dTimeFrom > dplaceTo || dTimeTo > dplaceTo) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dTimeFrom >= dplaceFrom && dTimeTo <= dplaceTo) {
          QuerySnapshot alreadyBookings1 = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'place_id',
                isEqualTo: widget.placeId,
              )
              .where(
                'space_id',
                isEqualTo: widget.spaceId,
              )
              .where('milliseconds_from',
                  isGreaterThanOrEqualTo:
                      timestamp_from!.millisecondsSinceEpoch)
              .where('milliseconds_from',
                  isLessThan: timestamp_to!.millisecondsSinceEpoch)
              .get();
          if (alreadyBookings1.docs.isNotEmpty) {
            setState(() {
              can = false;
            });
            return;
          }
          QuerySnapshot alreadyBookings2 = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'place_id',
                isEqualTo: widget.placeId,
              )
              .where(
                'space_id',
                isEqualTo: widget.spaceId,
              )
              .where('milliseconds_to',
                  isGreaterThan: timestamp_from!.millisecondsSinceEpoch)
              .where('milliseconds_to',
                  isLessThanOrEqualTo: timestamp_to!.millisecondsSinceEpoch)
              .get();
          if (alreadyBookings2.docs.isNotEmpty) {
            setState(() {
              can = false;
            });
            return;
          }
          QuerySnapshot alreadyBookings3 = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'place_id',
                isEqualTo: widget.placeId,
              )
              .where(
                'space_id',
                isEqualTo: widget.spaceId,
              )
              .where('milliseconds_to',
                  isGreaterThanOrEqualTo: timestamp_to!.millisecondsSinceEpoch)
              .get();
          if (alreadyBookings3.docs.isNotEmpty) {
            for (QueryDocumentSnapshot book in alreadyBookings3.docs) {
              if (book.get('milliseconds_from') <=
                  timestamp_from!.millisecondsSinceEpoch) {
                setState(() {
                  can = false;
                });
                return;
              }
            }
          }
        }
      }
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(selectedDate);
        _dow = DateFormat.E().format(selectedDate);
        isDate1 = true;
      });
      QuerySnapshot data1 = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('timestamp_from')
          .where(
            'date',
            isEqualTo: selectedDate,
          )
          .where(
            'place_id',
            isEqualTo: widget.placeId,
          )
          .where(
            'space_id',
            isEqualTo: widget.spaceId,
          )
          .get();
      alreadyBookings = data1.docs;
      if (_dow != null && isDate1 && isTime1 && isTime2) {
        setState(() {
          timestamp_from = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime.hour, selectedTime.minute);
          timestamp_to = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime2.hour, selectedTime2.minute);
          loading1 = true;
          verifying = true;
        });
        verify();
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();
        isTime1 = true;
      });
      if (_dow != null && isDate1 && isTime1 && isTime2) {
        setState(() {
          timestamp_from = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime.hour, selectedTime.minute);
          timestamp_to = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime2.hour, selectedTime2.minute);
          loading1 = true;
          verifying = true;
        });
        verify();
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> selectTime2(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime2,
    );
    if (picked != null) {
      setState(() {
        selectedTime2 = picked;
        _timeController2.text = formatDate(
            DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
            [HH, ':', nn]).toString();
        isTime2 = true;
      });
      if (_dow != null && isDate1 && isTime1 && isTime2) {
        setState(() {
          timestamp_from = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime.hour, selectedTime.minute);
          timestamp_to = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedTime2.hour, selectedTime2.minute);
          verifying = true;
          loading1 = true;
        });
        verify();
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('footyuz.web.app');
      if (response.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
      }
    } on SocketException catch (err) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                title: Text(Languages.of(context)!.serviceScreenNoInternet),
                // content: Text(Languages.of(context).profileScreenWantToLeave),
                actions: <Widget>[
                  IconButton(
                    onPressed: () async {
                      try {
                        final response =
                            await InternetAddress.lookup('footyuz.web.app');
                        if (response.isNotEmpty) {
                          Navigator.of(context).pop(false);
                          setState(() {
                            isConnected = true;
                          });
                        }
                      } on SocketException catch (err) {
                        setState(() {
                          isConnected = false;
                        });
                        print(err);
                      }
                    },
                    icon: const Icon(CupertinoIcons.arrow_2_circlepath),
                    iconSize: 20,
                  ),
                ],
              ));
        },
      );
      setState(() {
        isConnected = false;
      });
      print(err);
    }
  }

  Future<void> prepare() async {
    await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get()
        .then((value) {
      setState(() {
        place = value;
        loading = false;
        space = value
            .get('spaces')
            .where((element) => element['id'] == widget.spaceId)
            .first;
      });
    });
  }

  @override
  void initState() {
    prepare();
    _checkInternetConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return loading
        ? const LoadingScreen()
        : SingleChildScrollView(
            child: Container(
              color: const Color.fromRGBO(247, 247, 247, 1.0),
              margin: const EdgeInsets.all(10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Mon',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Mon']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Mon']['from'] +
                                ' - ' +
                                place!.get('days')['Mon']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Mon']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Tue',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Tue']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Tue']['from'] +
                                ' - ' +
                                place!.get('days')['Tue']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Tue']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Wed',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Wed']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Wed']['from'] +
                                ' - ' +
                                place!.get('days')['Wed']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Wed']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Thu',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Thu']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Thu']['from'] +
                                ' - ' +
                                place!.get('days')['Thu']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Thu']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Fri',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Fri']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Fri']['from'] +
                                ' - ' +
                                place!.get('days')['Fri']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Fri']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Sat',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Sat']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Sat']['from'] +
                                ' - ' +
                                place!.get('days')['Sat']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Sat']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Text(
                            'Sun',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        place!.get('days')['Sun']['status'] == 'closed'
                            ? Languages.of(context)!.serviceScreenClosed
                            : place!.get('days')['Sun']['from'] +
                                ' - ' +
                                place!.get('days')['Sun']['to'],
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color:
                                place!.get('days')['Sun']['status'] == 'closed'
                                    ? Colors.red
                                    : darkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  space['isFree']
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              Languages.of(context)!.serviceScreenDate,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: darkColor,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                selectDate(context);
                              },
                              child: Container(
                                width: _width! * 0.5,
                                height: _height! * 0.1,
                                margin: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: lightPrimaryColor,
                                    borderRadius: BorderRadius.circular(30)),
                                child: TextFormField(
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      fontSize: 27,
                                      color: whiteColor,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  controller: _dateController,
                                  onSaved: (String? val) {
                                    // _setDate = val;
                                  },
                                  decoration: const InputDecoration(
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      contentPadding:
                                          EdgeInsets.only(top: 0.0)),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  _dow != null
                      ? place!.get('days')[_dow]['status'] == 'closed'
                          ? Container()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                color: const Color.fromRGBO(247, 247, 247, 1.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    alreadyBookings.isNotEmpty
                                        ? Center(
                                            child: Text(
                                              Languages.of(context)!
                                                  .serviceScreenAlreadyBooked,
                                              style: GoogleFonts.montserrat(
                                                textStyle: const TextStyle(
                                                  color: darkColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    for (QueryDocumentSnapshot book
                                        in alreadyBookings)
                                      Center(
                                        child: Text(
                                          book.get('from').toString() +
                                              ' - ' +
                                              book.get('to').toString(),
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              color: darkColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                      : Container(),
                  space['isFree']
                      ? Row(
                          children: <Widget>[
                            Text(
                              Languages.of(context)!.serviceScreenFrom,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: darkColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                selectTime(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                width: _width! * 0.3,
                                height: _height! * 0.085,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: lightPrimaryColor,
                                    borderRadius: BorderRadius.circular(30)),
                                child: TextFormField(
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  onSaved: (String? val) {
                                    // _setTime = val;
                                  },
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  controller: _timeController,
                                  decoration: const InputDecoration(
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      // labelText: 'Time',
                                      contentPadding: EdgeInsets.all(5)),
                                ),
                              ),
                            ),
                            Text(
                              Languages.of(context)!.serviceScreenTo,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: darkColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            // widget.data['isFixed'] != null && widget.data['isFixed']
                            //     ? _time2 != null
                            //         ? Text(
                            //             '  ' + _time2,
                            //             style: GoogleFonts.montserrat(
                            //               textStyle: const TextStyle(
                            //                 color: darkColor,
                            //                 fontSize: 20,
                            //               ),
                            //             ),
                            //           )
                            //         : Container()
                            //     :
                            InkWell(
                              onTap: () {
                                selectTime2(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                width: _width! * 0.3,
                                height: _height! * 0.085,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: lightPrimaryColor,
                                    borderRadius: BorderRadius.circular(30)),
                                child: TextFormField(
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  onSaved: (String? val) {},
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  controller: _timeController2,
                                  decoration: const InputDecoration(
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      // labelText: 'Time',
                                      contentPadding: EdgeInsets.all(5)),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  space['isFree']
                      ? verifying
                          ? SizedBox(
                              width: size.width * 0.8,
                              child: Card(
                                elevation: 10,
                                child: loading1
                                    ? Container()
                                    : verified
                                        ? Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    Languages.of(context)!
                                                            .serviceScreenFrom +
                                                        ' ' +
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                timestamp_from!)
                                                            .toString() +
                                                        ' ' +
                                                        DateFormat.Hm()
                                                            .format(
                                                                timestamp_from!)
                                                            .toString(),
                                                    maxLines: 3,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle:
                                                          const TextStyle(
                                                        color: darkColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    Languages.of(context)!
                                                            .serviceScreenTo +
                                                        ' ' +
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                timestamp_to!)
                                                            .toString() +
                                                        ' ' +
                                                        DateFormat.Hm()
                                                            .format(
                                                                timestamp_to!)
                                                            .toString(),
                                                    maxLines: 3,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle:
                                                          const TextStyle(
                                                        color: darkColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    price.toString() + " UZS ",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle:
                                                          const TextStyle(
                                                        color: darkColor,
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 30),
                                                  Text(
                                                    Languages.of(context)!
                                                        .serviceScreenPaymentMethod,
                                                    maxLines: 2,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle:
                                                          const TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      place!
                                                              .get(
                                                                  'payment_methods')
                                                              .contains('cash')
                                                          ? CupertinoButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              onPressed: () {
                                                                if (payment_way ==
                                                                    'cash') {
                                                                  setState(() {
                                                                    payment_way =
                                                                        '';
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    payment_way =
                                                                        'cash';
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: payment_way ==
                                                                          'cash'
                                                                      ? primaryColor
                                                                      : whiteColor,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: payment_way ==
                                                                              'cash'
                                                                          ? primaryColor.withOpacity(
                                                                              0.5)
                                                                          : darkColor
                                                                              .withOpacity(0.5),
                                                                      spreadRadius:
                                                                          5,
                                                                      blurRadius:
                                                                          7,
                                                                      offset: const Offset(
                                                                          0,
                                                                          3), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                ),
                                                                width:
                                                                    size.width *
                                                                        0.3,
                                                                height: 100,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .money_dollar,
                                                                      size: 40,
                                                                      color: payment_way ==
                                                                              'cash'
                                                                          ? whiteColor
                                                                          : darkPrimaryColor,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      payment_way ==
                                                                              'cash'
                                                                          ? 'Done'
                                                                          : Languages.of(context)!
                                                                              .serviceScreenCash,
                                                                      maxLines:
                                                                          3,
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color: payment_way == 'cash'
                                                                              ? whiteColor
                                                                              : darkPrimaryColor,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      place!
                                                              .get(
                                                                  'payment_methods')
                                                              .contains('card')
                                                          ? CupertinoButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              onPressed: () {
                                                                if (payment_way ==
                                                                    'card') {
                                                                  setState(() {
                                                                    payment_way =
                                                                        '';
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    payment_way =
                                                                        'card';
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: payment_way ==
                                                                          'card'
                                                                      ? primaryColor
                                                                      : whiteColor,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: payment_way ==
                                                                              'card'
                                                                          ? primaryColor.withOpacity(
                                                                              0.5)
                                                                          : darkColor
                                                                              .withOpacity(0.5),
                                                                      spreadRadius:
                                                                          5,
                                                                      blurRadius:
                                                                          7,
                                                                      offset: const Offset(
                                                                          0,
                                                                          3), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                ),
                                                                width:
                                                                    size.width *
                                                                        0.3,
                                                                height: 100,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .creditcard,
                                                                      size: 40,
                                                                      color: payment_way ==
                                                                              'card'
                                                                          ? whiteColor
                                                                          : darkPrimaryColor,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      payment_way ==
                                                                              'card'
                                                                          ? 'Done'
                                                                          : Languages.of(context)!
                                                                              .serviceScreenCreditCard,
                                                                      maxLines:
                                                                          3,
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color: payment_way == 'card'
                                                                              ? whiteColor
                                                                              : darkPrimaryColor,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 35,
                                                  ),
                                                  payment_way.isNotEmpty
                                                      ? Center(
                                                          child: Builder(
                                                            builder: (context) =>
                                                                RoundedButton(
                                                              ph: 40,
                                                              pw: 100,
                                                              text: 'Book',
                                                              press: () async {
                                                                setState(() {
                                                                  loading =
                                                                      true;
                                                                });
                                                                await bookButton();
                                                                try {
                                                                  final response =
                                                                      await InternetAddress
                                                                          .lookup(
                                                                              'easarkuz.web.app');
                                                                  if (response
                                                                      .isNotEmpty) {
                                                                    setState(
                                                                        () {
                                                                      isConnected =
                                                                          true;
                                                                    });

                                                                    DocumentSnapshot checkPlace = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "parking_places")
                                                                        .doc(widget
                                                                            .placeId)
                                                                        .get();
                                                                    if (!checkPlace
                                                                        .get(
                                                                            "is_active")) {
                                                                      setState(
                                                                          () {
                                                                        can =
                                                                            false;
                                                                      });
                                                                      PushNotificationMessage
                                                                          notification =
                                                                          PushNotificationMessage(
                                                                        title:
                                                                            'Failed',
                                                                        body:
                                                                            'Owner closed parking',
                                                                      );
                                                                      showSimpleNotification(
                                                                        Text(notification
                                                                            .body),
                                                                        position:
                                                                            NotificationPosition.top,
                                                                        background:
                                                                            Colors.red,
                                                                      );
                                                                    }
                                                                    for (Map space
                                                                        in checkPlace
                                                                            .get('spaces')) {
                                                                      if (space[
                                                                              'id'] ==
                                                                          widget
                                                                              .spaceId) {
                                                                        if (!space[
                                                                            'isActive']) {
                                                                          setState(
                                                                              () {
                                                                            can =
                                                                                false;
                                                                          });
                                                                          PushNotificationMessage
                                                                              notification =
                                                                              PushNotificationMessage(
                                                                            title:
                                                                                'Failed',
                                                                            body:
                                                                                'Owner deactivated parking lot',
                                                                          );
                                                                          showSimpleNotification(
                                                                            Text(notification.body),
                                                                            position:
                                                                                NotificationPosition.top,
                                                                            background:
                                                                                Colors.red,
                                                                          );
                                                                        }
                                                                      }
                                                                    }
                                                                    if (can) {
                                                                      String id = DateTime
                                                                              .now()
                                                                          .millisecondsSinceEpoch
                                                                          .toString();
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'bookings')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'place_id':
                                                                            widget.placeId,
                                                                        'space_id':
                                                                            widget.spaceId,
                                                                        'client_id': FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid,
                                                                        'date':
                                                                            selectedDate.toString(),
                                                                        'owner_id':
                                                                            place!.get('owner_id'),
                                                                        'currency':
                                                                            place!.get('currency'),
                                                                        'price':
                                                                            price.roundToDouble(),
                                                                        'from': formatDate(
                                                                            timestamp_from!, [
                                                                          HH,
                                                                          ':',
                                                                          nn
                                                                        ]).toString(),
                                                                        'to': formatDate(
                                                                            timestamp_to!, [
                                                                          HH,
                                                                          ':',
                                                                          nn
                                                                        ]).toString(),
                                                                        'timestamp_from':
                                                                            timestamp_from!,
                                                                        'timestamp_to':
                                                                            timestamp_to!,
                                                                        'milliseconds_from':
                                                                            timestamp_from!.millisecondsSinceEpoch,
                                                                        'milliseconds_to':
                                                                            timestamp_to!.millisecondsSinceEpoch,
                                                                        'status': place!.get('needs_verification')
                                                                            ? 'verification_needed'
                                                                            : 'unfinished',
                                                                        'deadline':
                                                                            timestamp_from!.subtract(const Duration(hours: 1)),
                                                                        'seen_status':
                                                                            'unseen',
                                                                        'isRated':
                                                                            false,
                                                                        'isReported':
                                                                            false,
                                                                        'payment_method':
                                                                            payment_way,
                                                                      }).catchError(
                                                                              (error) {
                                                                        PushNotificationMessage
                                                                            notification =
                                                                            PushNotificationMessage(
                                                                          title:
                                                                              'Fail',
                                                                          body:
                                                                              'Failed to make booking',
                                                                        );
                                                                        showSimpleNotification(
                                                                          Text(notification
                                                                              .body),
                                                                          position:
                                                                              NotificationPosition.top,
                                                                          background:
                                                                              Colors.red,
                                                                        );
                                                                        if (mounted) {
                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                false;
                                                                          });
                                                                        } else {
                                                                          loading =
                                                                              false;
                                                                        }
                                                                      });
                                                                      List
                                                                          tokens =
                                                                          [];
                                                                      DocumentSnapshot owner = await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .doc(place!
                                                                              .get('owner_id'))
                                                                          .get();
                                                                      if (owner.get("fcm_token_web") !=
                                                                              null &&
                                                                          owner.get("fcm_token_web") !=
                                                                              "") {
                                                                        tokens.add(
                                                                            owner.get("fcm_token_web"));
                                                                      }
                                                                      if (owner.get("fcm_token_android") !=
                                                                              null &&
                                                                          owner.get("fcm_token_android") !=
                                                                              "") {
                                                                        tokens.add(
                                                                            owner.get("fcm_token_android"));
                                                                      }
                                                                      if (owner.get("fcm_token_ios") !=
                                                                              null &&
                                                                          owner.get("fcm_token_ios") !=
                                                                              "") {
                                                                        tokens.add(
                                                                            owner.get("fcm_token_ios"));
                                                                      }

                                                                      sendMessage(
                                                                          tokens,
                                                                          "New booking",
                                                                          "You have new booking at " +
                                                                              place!.get("name"));

                                                                      // Here comes notification
                                                                      PushNotificationMessage
                                                                          notification =
                                                                          PushNotificationMessage(
                                                                        title:
                                                                            'Success',
                                                                        body:
                                                                            'Booking was successful',
                                                                      );
                                                                      showSimpleNotification(
                                                                        Text(notification
                                                                            .body),
                                                                        position:
                                                                            NotificationPosition.top,
                                                                        background:
                                                                            greenColor,
                                                                      );

                                                                      setState(
                                                                          () {
                                                                        _dateController
                                                                            .clear();
                                                                        _timeController
                                                                            .clear();
                                                                        _timeController2
                                                                            .clear();
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        duration =
                                                                            0;
                                                                        price =
                                                                            0;
                                                                        selectedTime = const TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        selectedTime2 = const TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        isDate1 =
                                                                            false;
                                                                        isDate2 =
                                                                            false;
                                                                        isTime1 =
                                                                            false;
                                                                        isTime2 =
                                                                            false;
                                                                        _dow =
                                                                            null;
                                                                        verified =
                                                                            false;
                                                                        loading1 =
                                                                            false;
                                                                        verifying =
                                                                            false;
                                                                        loading =
                                                                            false;
                                                                        can =
                                                                            true;
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        payment_way =
                                                                            '';
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        _dateController
                                                                            .clear();
                                                                        _timeController
                                                                            .clear();
                                                                        _timeController2
                                                                            .clear();
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        isDate1 =
                                                                            false;
                                                                        isDate2 =
                                                                            false;
                                                                        isTime1 =
                                                                            false;
                                                                        isTime2 =
                                                                            false;
                                                                        duration =
                                                                            0;
                                                                        price =
                                                                            0;
                                                                        selectedTime = const TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        selectedTime2 = const TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        _dow =
                                                                            null;
                                                                        verified =
                                                                            false;
                                                                        loading1 =
                                                                            false;
                                                                        verifying =
                                                                            false;
                                                                        loading =
                                                                            false;
                                                                        can =
                                                                            true;
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        payment_way =
                                                                            '';
                                                                      });
                                                                    }
                                                                  }
                                                                } on SocketException catch (err) {
                                                                  showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return WillPopScope(
                                                                        onWillPop:
                                                                            () async =>
                                                                                false,
                                                                        child:
                                                                            AlertDialog(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20.0),
                                                                          ),
                                                                          title:
                                                                              Text(Languages.of(context)!.serviceScreenNoInternet),
                                                                          // content: Text(Languages.of(context).profileScreenWantToLeave),
                                                                          actions: <
                                                                              Widget>[
                                                                            IconButton(
                                                                              onPressed: () async {
                                                                                try {
                                                                                  final response = await InternetAddress.lookup('footyuz.web.app');
                                                                                  if (response.isNotEmpty) {
                                                                                    Navigator.of(context).pop(false);
                                                                                    setState(() {
                                                                                      isConnected = true;
                                                                                    });
                                                                                  }
                                                                                } on SocketException catch (err) {
                                                                                  setState(() {
                                                                                    isConnected = false;
                                                                                  });
                                                                                  print(err);
                                                                                }
                                                                              },
                                                                              icon: const Icon(CupertinoIcons.arrow_2_circlepath),
                                                                              iconSize: 20,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                  setState(() {
                                                                    isConnected =
                                                                        false;
                                                                  });
                                                                  print(err);
                                                                }
                                                              },
                                                              color:
                                                                  darkPrimaryColor,
                                                              textColor:
                                                                  whiteColor,
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                error!,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                              ),
                            )
                          : Container()
                      : Container(),
                  SizedBox(
                    height: size.height * 0.2,
                  ),
                ],
              ),
            ),
          );
  }
}
