import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

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

  double? _height;
  double? _width;
  double duration = 0;
  double price = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  bool can = true;
  bool isConnected = false;

  // ignore: unused_field
  String? _setTime, _setTime2, _setDate, error;
  String? _hour, _minute, _time, _dow;
  String? _hour2, _minute2, _time2;
  String? dateTime;
  // ignore: non_constant_identifier_names
  String payment_way = '';

  List imgList = [];
  List<QueryDocumentSnapshot> alreadyBookings = [];

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = const TimeOfDay(hour: 00, minute: 00);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _timeController2 = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _timeController2.dispose();
    super.dispose();
  }

  Future<void> _verify(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          error = Languages.of(context)!.serviceScreenIncorrectDate;
          loading1 = false;
          verified = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            error = Languages.of(context)!.serviceScreenIncorrectTime;
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (place!.get('needs_verification')) {
      if (selectedDate.day == DateTime.now().day &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.year == DateTime.now().year) {
        if ((selectedTime.minute + selectedTime.hour * 60) -
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

    if (dtime1 >= dtime2) {
      setState(() {
        error = Languages.of(context)!.serviceScreenIncorrectTime;
        loading1 = false;
        verified = false;
      });
      return;
    } else {
      if (place!.get('vacation_days') != null &&
          place!
              .get('vacation_days')
              .contains(Timestamp.fromDate(selectedDate))) {
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
          if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
            setState(() {
              error = Languages.of(context)!.serviceScreenTooEarly;
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
            setState(() {
              error = Languages.of(context)!.serviceScreenTooLate;
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
            QuerySnapshot data = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'date',
                  isEqualTo: selectedDate.toString(),
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
            List _bookings = data.docs;
            for (DocumentSnapshot booking in _bookings) {
              TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(booking.get('to')));
              TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(booking.get('from')));
              double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
              double dbookingFrom =
                  bookingFrom.minute + bookingFrom.hour * 60.0;
              if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
            }

            setState(() {
              duration = dtime2 - dtime1;
              price = duration * place!.get('ppm');
              loading1 = false;
              verified = true;
            });
          }
        }
      }
    }
  }

  Future<void> _bookButton(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    // var bPlaceData = await FirebaseFirestore.instance
    //     .collection('locations')
    //     .doc(widget.placeId)
    //     .get();
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          can = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            can = false;
          });
          return;
        }
      }
    }

    if (dtime1 >= dtime2) {
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
        if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
          QuerySnapshot data = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'date',
                isEqualTo: selectedDate.toString(),
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
          List _bookings = data.docs;
          for (DocumentSnapshot booking in _bookings) {
            TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(booking.get('to')));
            TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(booking.get('from')));
            double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
            double dbookingFrom = bookingFrom.minute + bookingFrom.hour * 60.0;
            if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
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

  Future<Null> _selectDate(BuildContext context) async {
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
      });
      QuerySnapshot data1 = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('timestamp_date')
          .where(
            'date',
            isEqualTo: selectedDate.toString(),
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
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        if (int.parse(_minute!) < 10) {
          _minute = '0' + _minute!;
        }
        _time = _hour! + ':' + _minute!;
        _timeController.text = _time!;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();
        // if (widget.data['isFixed'] != null && widget.data['isFixed']) {
        //   int fixedHour = selectedTime.hour;
        //   int fixedMinute = selectedTime.minute + widget.data['fixedDuration'];
        //   while (fixedMinute >= 60) {
        //     fixedHour = fixedHour + 1;
        //     fixedMinute = fixedMinute - 60;
        //   }
        //   if (fixedHour > 23) {
        //     error = Languages.of(context).serviceScreenTooLate;
        //     loading1 = false;
        //     verified = false;
        //     String fixedMinuteString;
        //     if (fixedMinute < 10) {
        //       fixedMinuteString = '0' + fixedMinute.toString();
        //     } else {
        //       fixedMinuteString = fixedMinute.toString();
        //     }
        //     _time2 = fixedHour.toString() + ':' + fixedMinuteString;
        //   } else {
        //     String fixedMinuteString;
        //     if (fixedMinute < 10) {
        //       fixedMinuteString = '0' + fixedMinute.toString();
        //     } else {
        //       fixedMinuteString = fixedMinute.toString();
        //     }
        //     _time2 = fixedHour.toString() + ':' + fixedMinuteString;
        //     selectedTime2 = TimeOfDay(hour: fixedHour, minute: fixedMinute);
        //   }
        // }
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime2(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime2,
    );
    if (picked != null) {
      setState(() {
        selectedTime2 = picked;
        _hour2 = selectedTime2.hour.toString();
        _minute2 = selectedTime2.minute.toString();
        if (_minute2 == '0') {
          _minute2 = '00';
        } else if (int.parse(_minute2!) < 10) {
          _minute2 = '0' + _minute2!;
        }
        _time2 = _hour2! + ':' + _minute2!;
        _timeController2.text = _time2!;
        _timeController2.text = formatDate(
            DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
            [HH, ':', nn]).toString();
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          verifying = true;
          loading1 = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
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
      // print('HERERE');
      // print(value.data());
      setState(() {
        place = value;
        loading = false;
        space = value.get('spaces')[widget.spaceId];
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
                  Row(
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
                          _selectDate(context);
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
                              _setDate = val;
                            },
                            decoration: const InputDecoration(
                                disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.only(top: 0.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  Row(
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
                          _selectTime(context);
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
                              _setTime = val;
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
                          _selectTime2(context);
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
                              _setTime2 = val;
                            },
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
                  ),
                  const SizedBox(height: 10),
                  verifying
                      ? Container(
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
                                                DateFormat.yMMMd()
                                                    .format(selectedDate)
                                                    .toString(),
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
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
                                                        .serviceScreenFrom +
                                                    ' ' +
                                                    _time!,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
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
                                                    _time2!,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
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
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
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
                                                style: GoogleFonts.montserrat(
                                                  textStyle: const TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  place!
                                                          .get(
                                                              'payment_methods')
                                                          .contains('cash')
                                                      ? CupertinoButton(
                                                          padding:
                                                              EdgeInsets.zero,
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
                                                                      ? primaryColor
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : darkColor
                                                                          .withOpacity(
                                                                              0.5),
                                                                  spreadRadius:
                                                                      5,
                                                                  blurRadius: 7,
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
                                                            width: size.width *
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
                                                                      : Languages.of(
                                                                              context)!
                                                                          .serviceScreenCash,
                                                                  maxLines: 3,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: payment_way ==
                                                                              'cash'
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
                                                          .contains('octo')
                                                      ? CupertinoButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          onPressed: () {
                                                            if (payment_way ==
                                                                'octo') {
                                                              setState(() {
                                                                payment_way =
                                                                    '';
                                                              });
                                                            } else {
                                                              setState(() {
                                                                payment_way =
                                                                    'octo';
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: payment_way ==
                                                                      'octo'
                                                                  ? primaryColor
                                                                  : whiteColor,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: payment_way ==
                                                                          'octo'
                                                                      ? primaryColor
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : darkColor
                                                                          .withOpacity(
                                                                              0.5),
                                                                  spreadRadius:
                                                                      5,
                                                                  blurRadius: 7,
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
                                                            width: size.width *
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
                                                                          'octo'
                                                                      ? whiteColor
                                                                      : darkPrimaryColor,
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  payment_way ==
                                                                          'octo'
                                                                      ? 'Done'
                                                                      : Languages.of(
                                                                              context)!
                                                                          .serviceScreenCreditCard,
                                                                  maxLines: 3,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: payment_way ==
                                                                              'octo'
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
                                                              loading = true;
                                                            });
                                                            await _bookButton(
                                                              formatDate(
                                                                  DateTime(
                                                                      2019,
                                                                      08,
                                                                      1,
                                                                      selectedTime
                                                                          .hour,
                                                                      selectedTime.minute),
                                                                  [
                                                                    HH,
                                                                    ':',
                                                                    nn
                                                                  ]),
                                                              formatDate(
                                                                  DateTime(
                                                                      2019,
                                                                      08,
                                                                      1,
                                                                      selectedTime2
                                                                          .hour,
                                                                      selectedTime2.minute),
                                                                  [
                                                                    HH,
                                                                    ':',
                                                                    nn
                                                                  ]),
                                                            );
                                                            try {
                                                              final response =
                                                                  await InternetAddress
                                                                      .lookup(
                                                                          'footyuz.web.app');
                                                              if (response
                                                                  .isNotEmpty) {
                                                                setState(() {
                                                                  isConnected =
                                                                      true;
                                                                });
                                                                if (can) {
                                                                  String id = DateTime
                                                                          .now()
                                                                      .millisecondsSinceEpoch
                                                                      .toString();
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'bookings')
                                                                      .doc(id)
                                                                      .set({
                                                                    'place_id':
                                                                        widget
                                                                            .placeId,
                                                                    'space_id':
                                                                        widget
                                                                            .spaceId,
                                                                    'client_id': FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid,
                                                                    'price': price
                                                                        .roundToDouble(),
                                                                    'from':
                                                                        _time,
                                                                    'to':
                                                                        _time2,
                                                                    // 'date': selectedDate
                                                                    //     .toString(),
                                                                    'timestamp_date':
                                                                        selectedDate,
                                                                    'status': place!
                                                                            .get('needs_verification')
                                                                        ? 'verification_needed'
                                                                        : 'unfinished',
                                                                    'deadline':
                                                                        DateTime(
                                                                      selectedDate
                                                                          .year,
                                                                      selectedDate
                                                                          .month,
                                                                      selectedDate
                                                                          .day,
                                                                      int.parse(
                                                                              _hour!) -
                                                                          1,
                                                                      int.parse(
                                                                          _minute!),
                                                                    ),
                                                                    'seen_status':
                                                                        'unseen',
                                                                    'isRated':
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
                                                                          NotificationPosition
                                                                              .top,
                                                                      background:
                                                                          Colors
                                                                              .red,
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

                                                                  // Here comes notification

                                                                  setState(() {
                                                                    _dateController
                                                                        .clear();
                                                                    _timeController
                                                                        .clear();
                                                                    _timeController2
                                                                        .clear();
                                                                    selectedDate =
                                                                        DateTime
                                                                            .now();
                                                                    _time =
                                                                        null;
                                                                    _time2 =
                                                                        null;
                                                                    duration =
                                                                        0;
                                                                    price = 0;
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
                                                                    _setDate =
                                                                        null;
                                                                    _dow = null;
                                                                    verified =
                                                                        false;
                                                                    loading1 =
                                                                        false;
                                                                    verifying =
                                                                        false;
                                                                    loading =
                                                                        false;
                                                                    can = true;
                                                                    selectedDate =
                                                                        DateTime
                                                                            .now();
                                                                    payment_way =
                                                                        '';
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    _dateController
                                                                        .clear();
                                                                    _timeController
                                                                        .clear();
                                                                    _timeController2
                                                                        .clear();
                                                                    selectedDate =
                                                                        DateTime
                                                                            .now();
                                                                    _time =
                                                                        null;
                                                                    _time2 =
                                                                        null;
                                                                    duration =
                                                                        0;
                                                                    price = 0;
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
                                                                    _setDate =
                                                                        null;
                                                                    _dow = null;
                                                                    verified =
                                                                        false;
                                                                    loading1 =
                                                                        false;
                                                                    verifying =
                                                                        false;
                                                                    loading =
                                                                        false;
                                                                    can = true;
                                                                    selectedDate =
                                                                        DateTime
                                                                            .now();
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
                                                                      title: Text(
                                                                          Languages.of(context)!
                                                                              .serviceScreenNoInternet),
                                                                      // content: Text(Languages.of(context).profileScreenWantToLeave),
                                                                      actions: <
                                                                          Widget>[
                                                                        IconButton(
                                                                          onPressed:
                                                                              () async {
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
                                                                          icon:
                                                                              const Icon(CupertinoIcons.arrow_2_circlepath),
                                                                          iconSize:
                                                                              20,
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
                                                          textColor: whiteColor,
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                              // Builder(
                                              //   builder: (context) =>
                                              //       RoundedButton(
                                              //     width: 0.5,
                                              //     height: 0.07,
                                              //     text: 'Book',
                                              //     press: () {
                                              //       setState(() {
                                              //         loading = true;
                                              //       });
                                              //       FirebaseFirestore
                                              //           .instanceProfit
                                              //           .collection(
                                              //               'bookings')
                                              //           .doc()
                                              //           .set({
                                              //         'placeId':
                                              //             widget.placeId,
                                              //         'serviceId': widget
                                              //             .serviceId,
                                              //         'userId':
                                              //             FirebaseAuth
                                              //                 .instance
                                              //                 .currentUser
                                              //                 .uid,
                                              //         'price': price
                                              //             .roundToDouble(),
                                              //         'from': _time,
                                              //         'to': _time2,
                                              //         'date': selectedDate
                                              //             .toString(),
                                              //         'timestamp_date':
                                              //             selectedDate,
                                              //         'status': widget.data[
                                              //                     'type'] ==
                                              //                 'nonver'
                                              //             ? 'unfinished'
                                              //             : 'verification_needed',
                                              //         'seen_status':
                                              //             'unseen',
                                              //         'isRated': false,
                                              //       });
                                              //       setState(() {
                                              //         selectedDate =
                                              //             DateTime.now();
                                              //         _time = null;
                                              //         _time2 = null;
                                              //         duration = 0;
                                              //         price = 0;
                                              //         selectedTime =
                                              //             TimeOfDay(
                                              //                 hour: 00,
                                              //                 minute: 00);
                                              //         selectedTime2 =
                                              //             TimeOfDay(
                                              //                 hour: 00,
                                              //                 minute: 00);
                                              //         verified = false;
                                              //         loading1 = false;
                                              //         verifying = false;
                                              //         loading = false;
                                              //         selectedDate =
                                              //             DateTime.now();
                                              //         Scaffold.of(context)
                                              //             .showSnackBar(
                                              //           SnackBar(
                                              //             backgroundColor:
                                              //                 darkPrimaryColor,
                                              //             content: Text(
                                              //               'Booking was successful',
                                              //               style: GoogleFonts
                                              //                   .montserrat(
                                              //                 textStyle:
                                              //                     TextStyle(
                                              //                   color:
                                              //                       whiteColor,
                                              //                   fontSize:
                                              //                       30,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         );
                                              //       });
                                              //     },
                                              //     color: darkPrimaryColor,
                                              //     textColor: whiteColor,
                                              //   ),
                                              // ),
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
