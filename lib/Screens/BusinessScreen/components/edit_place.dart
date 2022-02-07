import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Screens/BusinessScreen/components/place_screen.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:overlay_support/overlay_support.dart';

class EditPlaceScreen extends StatefulWidget {
  String placeId;
  EditPlaceScreen({
    Key? key,
    required this.placeId,
  }) : super(key: key);
  @override
  _EditPlaceScreenState createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  int? price;
  bool? isFixedPrice = false;
  bool? isppm = false;
  bool? is24hours = false;
  bool? isFreeTiming = false;
  bool? isStandardTiming = false;
  String? description;
  String? name;
  String? timing_mode;
  String? pricing_mode;
  String? currency = 'UZS';
  bool needsVer = false;
  bool? remoteConfigUpdated;
  String error = '';
  File? i1, i2, i3, i4, i5, i6;
  String? country;
  String? state;
  String? city;
  RemoteConfig remoteConfig = RemoteConfig.instance;
  DocumentSnapshot? place;

  String selectedDay = '';
  String? _hour, _minute, _time;
  String? _hour2, _minute2, _time2;
  // ignore: non_constant_identifier_names
  List payment_methods = [];
  List currencies = [];
  Map mon = {};
  Map tue = {};
  Map wed = {};
  Map thu = {};
  Map fri = {};
  Map sat = {};
  Map sun = {};

  DateTime selectedDate = DateTime.now();

  final TextEditingController _dateController = TextEditingController();

  List vacationDays = [];

  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = const TimeOfDay(hour: 00, minute: 00);
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _timeController2 = TextEditingController();
  bool workingDay = true;
  bool fixedDuration = false;

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('parking_places')
        .doc(widget.placeId)
        .get();
    setState(() {
      price = place!.get("price");
      isFixedPrice = place!.get("isFixedPrice");
      isppm = place!.get("isppm");
      is24hours = place!.get("is24");
      isFreeTiming = place!.get("isFreeTiming");
      isStandardTiming = place!.get("isStandardTiming");
      is24hours = place!.get("is24");
      description = place!.get('description');
      name = place!.get('name');
      timing_mode = place!.get('timing_mode');
      pricing_mode = place!.get('pricing_mode');
      currency = place!.get('currency');
      needsVer = place!.get('needs_verification');
      vacationDays = place!.get('vacation_days');
      payment_methods = place!.get('payment_methods');
      country = place!.get('country');
      state = place!.get('state');
      city = place!.get('city');
      mon = {
        'status': place!.get('days')['Mon']['status'],
        'from': place!.get('days')['Mon']['from'],
        'to': place!.get('days')['Mon']['to']
      };
      tue = {
        'status': place!.get('days')['Tue']['status'],
        'from': place!.get('days')['Tue']['from'],
        'to': place!.get('days')['Tue']['to']
      };
      wed = {
        'status': place!.get('days')['Wed']['status'],
        'from': place!.get('days')['Wed']['from'],
        'to': place!.get('days')['Wed']['to']
      };
      thu = {
        'status': place!.get('days')['Thu']['status'],
        'from': place!.get('days')['Thu']['from'],
        'to': place!.get('days')['Thu']['to']
      };
      fri = {
        'status': place!.get('days')['Fri']['status'],
        'from': place!.get('days')['Fri']['from'],
        'to': place!.get('days')['Fri']['to']
      };
      sat = {
        'status': place!.get('days')['Sat']['status'],
        'from': place!.get('days')['Sat']['from'],
        'to': place!.get('days')['Sat']['to']
      };
      sun = {
        'status': place!.get('days')['Sun']['status'],
        'from': place!.get('days')['Sun']['from'],
        'to': place!.get('days')['Sun']['to']
      };
    });
    remoteConfigUpdated = await remoteConfig.fetchAndActivate().then((value) {
      setState(() {
        currencies = jsonDecode(remoteConfig
            .getValue('available_currencies')
            .asString())['currencies'];
        loading = false;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
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
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
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
      });
      if (_time != null && _time2 != null) {
        _verify();
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'from': _time,
                'status': tue['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'from': _time,
                'status': wed['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'from': _time,
                'status': thu['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'from': _time,
                'status': fri['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'from': _time,
                'status': sat['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'from': _time,
                'status': sun['to'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
        }
      } else {
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'from': _time,
                'status': tue['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'from': _time,
                'status': wed['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'from': _time,
                'status': thu['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'from': _time,
                'status': fri['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'from': _time,
                'status': sat['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'from': _time,
                'status': sun['to'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
        }
      }
    }
  }

  Future<void> _selectTime2(BuildContext context) async {
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
      if (_time != null && _time2 != null) {
        _verify();
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'to': _time2,
                'status': tue['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'to': _time2,
                'status': wed['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'to': _time2,
                'status': thu['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'to': _time2,
                'status': fri['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'to': _time2,
                'status': sat['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'to': _time2,
                'status': sun['from'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
        }
      } else {
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'to': _time2,
                'status': tue['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'to': _time2,
                'status': wed['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'to': _time2,
                'status': thu['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'to': _time2,
                'status': fri['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'to': _time2,
                'status': sat['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'to': _time2,
                'status': sun['from'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
        }
      }
    }
  }

  Future<void> _verify() async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;

    if (dtime1 >= dtime2) {
      setState(() {
        error = 'Incorrect time selected';
      });
      return;
    } else {
      setState(() {
        error = '';
      });
    }
  }

  Future _getImage(int i) async {
    var picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (picker != null) {
        switch (i) {
          case 1:
            i1 = File(picker.path);
            break;
          case 2:
            i2 = File(picker.path);
            break;
          case 3:
            i3 = File(picker.path);
            break;
          case 4:
            i4 = File(picker.path);
            break;
          case 5:
            i5 = File(picker.path);
            break;
          case 6:
            i6 = File(picker.path);
            break;
          default:
            i1 = File(picker.path);
        }
        error = '';
      } else {
        // print('No image selected.');
      }
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
              // title: Text(
              //   'Info',
              //   textScaleFactor: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: GoogleFonts.montserrat(
              //     textStyle: const TextStyle(
              //         color: darkColor, fontSize: 20, fontWeight: FontWeight.w300),
              //   ),
              // ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          'Edit place #' + place!.id,
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: size.width * 0.8,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                'General',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 20),
                              TextFormField(
                                validator: (val) => val!.length >= 5
                                    ? null
                                    : 'Minimum 5 characters',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  name = val;
                                },
                                initialValue: name,
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  hintStyle: TextStyle(
                                      color: darkColor.withOpacity(0.7)),
                                  hintText: 'Name',
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                validator: (val) => val!.length >= 5
                                    ? null
                                    : 'Minimum 5 characters',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  description = val;
                                },
                                initialValue: description,
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  hintStyle: TextStyle(
                                      color: darkColor.withOpacity(0.7)),
                                  hintText: 'Description',
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 30),

                              DropdownButton<String>(
                                value: currency,
                                hint: Text(
                                  'Currency',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                items: currencies != null
                                    ? currencies.map((dynamic value) {
                                        return DropdownMenuItem<String>(
                                          value: value.toString().toUpperCase(),
                                          child: Text(value),
                                        );
                                      }).toList()
                                    : [
                                        const DropdownMenuItem<String>(
                                          value: '-',
                                          child: Text('-'),
                                        )
                                      ],
                                onChanged: (value) {
                                  setState(() {
                                    currency = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 30),
                              Row(
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
                                    child: Text(
                                      'There are two types of pricing: \n\n' +
                                          '-\bFixed \bprice is when you set a fixed price for all orders, no matter of their duration and etc. For example if you set 100 UZS fixed price, it will be the same for every booking. \n\n' +
                                          '-\bPrice \bper \bminute is when you set a price for using your parking for one minute. For example, is price per minute is 100 UZS, booking your paring place for 1 hour will cost 6000 UZS',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 100,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              DropdownButtonFormField<String>(
                                value: isppm!
                                    ? 'ppm'
                                    : isFixedPrice!
                                        ? 'fixedPrice'
                                        : '',
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Choose pricing mode';
                                  } else {
                                    if (pricing_mode!.isEmpty) {
                                      return 'Choose pricing mode';
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                                hint: Text(
                                  isppm!
                                      ? 'Price per minute'
                                      : isFixedPrice!
                                          ? 'Fixed price'
                                          : 'Pricing mode',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'fixedPrice',
                                    child: Text('Fixed price'),
                                  ),
                                  const DropdownMenuItem<String>(
                                    value: 'ppm',
                                    child: Text('Price per minute'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    pricing_mode = value;
                                  });
                                  switch (value) {
                                    case 'ppm':
                                      setState(() {
                                        isppm = true;
                                        isFixedPrice = false;
                                      });
                                      break;
                                    case 'fixedPrice':
                                      setState(() {
                                        isFixedPrice = true;
                                        isppm = false;
                                      });
                                      break;
                                  }
                                },
                              ),

                              const SizedBox(height: 30),
                              Text(
                                isppm!
                                    ? 'Price of the parking: ' +
                                        currency! +
                                        ' per minute'
                                    : 'Fixed price: ' + currency!,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                validator: (val) =>
                                    val!.isNotEmpty ? null : 'Minimum 1 number',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.number,
                                initialValue: price.toString(),
                                onChanged: (val) {
                                  price = int.parse(val);
                                },
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  hintStyle: TextStyle(
                                      color: darkColor.withOpacity(0.7)),
                                  hintText: isppm!
                                      ? 'Price per minute: ' + currency!
                                      : isFixedPrice!
                                          ? 'Fixed price: ' + currency!
                                          : '',
                                  border: InputBorder.none,
                                ),
                              ),

                              const SizedBox(height: 30),
                              CSCPicker(
                                currentState: state,
                                currentCountry: country,
                                currentCity: city,
                                flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                onCountryChanged: (value) {
                                  setState(() {
                                    country = value;
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    state = value;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    city = value;
                                  });
                                },
                              ),

                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Available payment methods',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (payment_methods.contains('cash')) {
                                        setState(() {
                                          payment_methods.remove('cash');
                                        });
                                      } else {
                                        setState(() {
                                          payment_methods.add('cash');
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: payment_methods.contains('cash')
                                            ? lightPrimaryColor
                                            : whiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: payment_methods
                                                    .contains('cash')
                                                ? primaryColor.withOpacity(0.5)
                                                : darkColor.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle,
                                      ),
                                      width: size.width * 0.3,
                                      height: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.money_dollar,
                                            size: 40,
                                            color:
                                                payment_methods.contains('cash')
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            payment_methods.contains('cash')
                                                ? 'Done'
                                                : 'Cash',
                                            maxLines: 3,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: payment_methods
                                                        .contains('cash')
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (payment_methods.contains('card')) {
                                        setState(() {
                                          payment_methods.remove('card');
                                        });
                                      } else {
                                        setState(() {
                                          payment_methods.add('card');
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: payment_methods.contains('card')
                                            ? lightPrimaryColor
                                            : whiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: payment_methods
                                                    .contains('card')
                                                ? primaryColor.withOpacity(0.5)
                                                : darkColor.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        shape: BoxShape.rectangle,
                                      ),
                                      width: size.width * 0.3,
                                      height: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.creditcard,
                                            size: 40,
                                            color:
                                                payment_methods.contains('card')
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            payment_methods.contains('card')
                                                ? 'Done'
                                                : 'Credit card',
                                            maxLines: 3,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: payment_methods
                                                        .contains('card')
                                                    ? whiteColor
                                                    : darkPrimaryColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // IMPORTANT

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [
                              //     Icon(
                              //       CupertinoIcons.info_circle,
                              //       color: darkPrimaryColor,
                              //       size: 30,
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Expanded(
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'If you turn on VERIFICATION, when client wants to make booking, your agreement is needed to complete booking. if you turn verification OFF, then clients will be able to make bookings automatically, without your agreement.',
                              //             overflow: TextOverflow.ellipsis,
                              //             maxLines: 200,
                              //             textAlign: TextAlign.center,
                              //             style: GoogleFonts.montserrat(
                              //               textStyle: TextStyle(
                              //                 color: darkPrimaryColor,
                              //                 fontSize: 15,
                              //               ),
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 7,
                              //       child: Text(
                              //         'Turn on verification?',
                              //         overflow: TextOverflow.ellipsis,
                              //         style: GoogleFonts.montserrat(
                              //           textStyle: TextStyle(
                              //             color: darkColor,
                              //             fontSize: 17,
                              //             fontWeight: FontWeight.w400,
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(width: 5),
                              //     Align(
                              //       alignment: Alignment.centerRight,
                              //       child: Switch(
                              //         activeColor: primaryColor,
                              //         value: needsVer,
                              //         onChanged: (val) {
                              //           if (this.mounted) {
                              //             setState(() {
                              //               this.needsVer = val;
                              //             });
                              //           }
                              //         },
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                'Time management',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 30),
                              Row(
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
                                    child: Text(
                                      'There are three types types of timing: \n\n' +
                                          '-\bStandard \btiming is when client books your parking place from time to another. For example, client can book your parking place from 7 am to 9 am. However, booking cannot last more than one day\n\n' +
                                          '-\b24/7 \btiming is the same as \bStandard \btiming. However, bookings can last for more than one day. For this option your parking place should be open 24/7\n\n' +
                                          '-\bFree \btiming is when there is no start and end times for booking. Client just uses your parking place for as long as needed. In this case price will increase as duration of parking increases.',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 100,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              DropdownButtonFormField<String>(
                                value: isStandardTiming!
                                    ? 'standard'
                                    : is24hours!
                                        ? '24hours'
                                        : isFreeTiming!
                                            ? 'free'
                                            : '',
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Choose timing mode';
                                  } else {
                                    if (timing_mode!.isEmpty) {
                                      return 'Choose timing mode';
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                                hint: Text(
                                  isStandardTiming!
                                      ? 'Standard timing'
                                      : is24hours!
                                          ? '24/7 timing'
                                          : isFreeTiming!
                                              ? 'Free timing'
                                              : 'Timing mode',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'standard',
                                    child: Text('Standard timing'),
                                  ),
                                  const DropdownMenuItem<String>(
                                    value: '24hours',
                                    child: Text('24/7 timing'),
                                  ),
                                  const DropdownMenuItem<String>(
                                    value: 'free',
                                    child: Text('Free timing'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    timing_mode = value;
                                  });
                                  switch (value) {
                                    case 'standard':
                                      setState(() {
                                        isStandardTiming = true;
                                        is24hours = false;
                                        isFreeTiming = false;
                                      });
                                      break;
                                    case '24hours':
                                      setState(() {
                                        isStandardTiming = false;
                                        is24hours = true;
                                        isFreeTiming = false;
                                      });
                                      break;
                                    case 'free':
                                      setState(() {
                                        isStandardTiming = false;
                                        is24hours = false;
                                        isFreeTiming = true;
                                      });
                                      break;
                                  }
                                },
                              ),
                              const SizedBox(height: 30),
                              !is24hours!
                                  ? !isFreeTiming!
                                      ? SizedBox(
                                          width: size.width * 0.9,
                                          height: 100,
                                          child: GridView.count(
                                            crossAxisCount: 7,
                                            crossAxisSpacing: 5,
                                            children: [
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (mon['status'] != null) {
                                                      if (mon['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'mon';
                                                    if (mon['status'] != null) {
                                                      _timeController.text =
                                                          mon['from'];
                                                      _timeController2.text =
                                                          mon['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: mon['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Mon',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'mon'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (tue['status'] != null) {
                                                      if (tue['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'tue';
                                                    if (tue['status'] != null) {
                                                      _timeController.text =
                                                          tue['from'];
                                                      _timeController2.text =
                                                          tue['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: tue['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Tue',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'tue'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (wed['status'] != null) {
                                                      if (wed['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'wed';
                                                    if (wed['status'] != null) {
                                                      _timeController.text =
                                                          wed['from'];
                                                      _timeController2.text =
                                                          wed['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: wed['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Wed',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'wed'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (thu['status'] != null) {
                                                      if (thu['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'thu';
                                                    if (thu['status'] != null) {
                                                      _timeController.text =
                                                          thu['from'];
                                                      _timeController2.text =
                                                          thu['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: thu['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Thu',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'thu'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (fri['status'] != null) {
                                                      if (fri['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'fri';
                                                    if (fri['status'] != null) {
                                                      _timeController.text =
                                                          fri['from'];
                                                      _timeController2.text =
                                                          fri['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: fri['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Fri',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'fri'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (sat['status'] != null) {
                                                      if (sat['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'sat';
                                                    if (sat['status'] != null) {
                                                      _timeController.text =
                                                          sat['from'];
                                                      _timeController2.text =
                                                          sat['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: sat['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Sat',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'sat'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              CupertinoButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _hour = null;
                                                    _minute = null;
                                                    _time = null;
                                                    _hour2 = null;
                                                    _minute2 = null;
                                                    _time2 = null;
                                                    selectedTime =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    selectedTime2 =
                                                        const TimeOfDay(
                                                            hour: 00,
                                                            minute: 00);
                                                    if (sun['status'] != null) {
                                                      if (sun['status'] ==
                                                          'open') {
                                                        workingDay = true;
                                                      } else {
                                                        workingDay = false;
                                                      }
                                                    } else {
                                                      workingDay = true;
                                                    }
                                                    selectedDay = 'sun';
                                                    if (sun['status'] != null) {
                                                      _timeController.text =
                                                          sun['from'];
                                                      _timeController2.text =
                                                          sun['to'];
                                                    } else {
                                                      _timeController.clear();
                                                      _timeController2.clear();
                                                    }
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: sun['status'] != null
                                                      ? const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .checkmark,
                                                            size: 20,
                                                            color: whiteColor,
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            'Sun',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selectedDay == 'sun'
                                                        ? lightPrimaryColor
                                                        : darkPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container()
                                  : Container(),
                              const SizedBox(height: 10),
                              !is24hours!
                                  ? !isFreeTiming!
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Working day?',
                                              style: GoogleFonts.montserrat(
                                                textStyle: const TextStyle(
                                                  color: darkColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Switch(
                                                activeColor: primaryColor,
                                                value: workingDay,
                                                onChanged: (val) {
                                                  if (mounted) {
                                                    setState(() {
                                                      workingDay = val;
                                                      switch (selectedDay) {
                                                        case 'mon':
                                                          setState(() {
                                                            mon.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'tue':
                                                          setState(() {
                                                            tue.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'wed':
                                                          setState(() {
                                                            wed.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'thu':
                                                          setState(() {
                                                            thu.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'fri':
                                                          setState(() {
                                                            fri.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'sat':
                                                          setState(() {
                                                            sat.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        case 'sun':
                                                          setState(() {
                                                            sun.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                          break;
                                                        default:
                                                          setState(() {
                                                            mon.addAll({
                                                              'status': 'closed'
                                                            });
                                                          });
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
                                  : Container(),
                              const SizedBox(height: 10),
                              !is24hours!
                                  ? !isFreeTiming!
                                      ? workingDay
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'From',
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _selectTime(context);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width: 70,
                                                    height: 50,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                lightPrimaryColor),
                                                    child: TextFormField(
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      onSaved: (val) {},
                                                      enabled: false,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          _timeController,
                                                      decoration:
                                                          const InputDecoration(
                                                              disabledBorder:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none),
                                                              // labelText: 'Time',
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'To',
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: darkColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _selectTime2(context);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width: 70,
                                                    height: 50,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                lightPrimaryColor),
                                                    child: TextFormField(
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      onSaved: (val) {},
                                                      enabled: false,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          _timeController2,
                                                      decoration:
                                                          const InputDecoration(
                                                              disabledBorder:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none),
                                                              // labelText: 'Time',
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()
                                      : Container()
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                'Vacation days',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _selectDate(context);
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 50,
                                      margin: const EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          color: lightPrimaryColor),
                                      child: TextFormField(
                                        style: GoogleFonts.montserrat(
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            color: whiteColor,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                        enabled: false,
                                        keyboardType: TextInputType.text,
                                        controller: _dateController,
                                        decoration: const InputDecoration(
                                            disabledBorder:
                                                UnderlineInputBorder(
                                                    borderSide:
                                                        BorderSide.none),
                                            contentPadding:
                                                EdgeInsets.only(top: 0.0)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  RoundedButton(
                                    pw: 70,
                                    ph: 45,
                                    text: 'Add',
                                    press: () {
                                      setState(() {
                                        if (!vacationDays
                                            .contains(selectedDate)) {
                                          vacationDays.add(selectedDate);
                                          selectedDate = DateTime.now();
                                          _dateController.clear();
                                        }
                                      });
                                    },
                                    color: primaryColor,
                                    textColor: whiteColor,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (vacationDays.isNotEmpty)
                                for (DateTime date in vacationDays)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(date)
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: const TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        iconSize: 20,
                                        color: Colors.red,
                                        icon: const Icon(
                                          CupertinoIcons.xmark_circle,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            vacationDays.remove(date);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: size.width * 0.8,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  'Pictures',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 20),
                                GridView.count(
                                  shrinkWrap: true,
                                  primary: false,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(1);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i1 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(0)
                                                ? place!.get('images')[0] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[0],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i1!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(2);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i2 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(1)
                                                ? place!.get('images')[1] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[1],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i2!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(3);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i3 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(2)
                                                ? place!.get('images')[2] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[2],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i3!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(4);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i4 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(3)
                                                ? place!.get('images')[3] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[3],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i4!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(5);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i5 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(4)
                                                ? place!.get('images')[4] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[4],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i5!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(6);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i6 == null
                                            ? place!
                                                    .get('images')
                                                    .asMap()
                                                    .containsKey(5)
                                                ? place!.get('images')[5] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        imageUrl: place!
                                                            .get('images')[5],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(
                                                        Icons.add,
                                                        color: whiteColor,
                                                      )
                                                : const Icon(
                                                    Icons.add,
                                                    color: whiteColor,
                                                  )
                                            : Image.file(i6!),
                                        color: darkColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedButton(
                      width: 0.7,
                      ph: 55,
                      text: 'CONTINUE',
                      press: () async {
                        if (_formKey.currentState!.validate()) {
                          if (i1 != null ||
                              i2 != null ||
                              i3 != null ||
                              i4 != null ||
                              i5 != null ||
                              i6 != null ||
                              place!.get('images')[0] != null ||
                              place!.get('images')[1] != null ||
                              place!.get('images')[2] != null ||
                              place!.get('images')[3] != null ||
                              place!.get('images')[4] != null ||
                              place!.get('images')[5] != null) {
                            setState(() {
                              loading = true;
                            });
                            TaskSnapshot? a1;
                            TaskSnapshot? a2;
                            TaskSnapshot? a3;
                            TaskSnapshot? a4;
                            TaskSnapshot? a5;
                            TaskSnapshot? a6;
                            String id = FirebaseAuth.instance.currentUser!.uid;

                            if (i1 != null) {
                              a1 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i1/')
                                  .putFile(i1!);
                            }
                            if (i2 != null) {
                              a2 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i2/')
                                  .putFile(i2!);
                            }
                            if (i3 != null) {
                              a3 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i3/')
                                  .putFile(i3!);
                            }
                            if (i4 != null) {
                              a4 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i4/')
                                  .putFile(i4!);
                            }
                            if (i5 != null) {
                              a5 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i5!);
                            }
                            if (i6 != null) {
                              a6 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i6!);
                            }
                            FirebaseFirestore.instance
                                .collection('parking_places')
                                .doc(place!.id)
                                .update({
                              'name': name,
                              'description': description,
                              'country': country,
                              'state': state,
                              'city': city,
                              'currency': currency,
                              'pricing_mode': pricing_mode,
                              'price': price,
                              'isppm': isppm,
                              'isFixedPrice': isFixedPrice,
                              'timing_mode': timing_mode,
                              'is24': is24hours,
                              'isStandardTiming': isStandardTiming,
                              'isFreeTiming': isFreeTiming,
                              'payment_methods': payment_methods,
                              'days': {
                                'Mon': mon,
                                'Tue': tue,
                                'Wed': wed,
                                'Thu': thu,
                                'Fri': fri,
                                'Sat': sat,
                                'Sun': sun,
                              },
                              'vacation_days': vacationDays,
                              'images': [
                                if (a1 != null)
                                  await a1.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(0))
                                  place!.get('images')[0],
                                if (a2 != null)
                                  await a2.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(1))
                                  place!.get('images')[1],
                                if (a3 != null)
                                  await a3.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(2))
                                  place!.get('images')[2],
                                if (a4 != null)
                                  await a4.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(3))
                                  place!.get('images')[3],
                                if (a5 != null)
                                  await a5.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(4))
                                  place!.get('images')[4],
                                if (a6 != null)
                                  await a6.ref.getDownloadURL()
                                else if (place!
                                    .get('images')
                                    .asMap()
                                    .containsKey(5))
                                  place!.get('images')[5],
                              ],
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
                            });
                            PushNotificationMessage notification =
                                PushNotificationMessage(
                              title: 'Success',
                              body: 'Updated',
                            );
                            showSimpleNotification(
                              Text(notification.body),
                              position: NotificationPosition.top,
                              background: greenColor,
                            );
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: PlaceScreen(
                                placeId: widget.placeId,
                              )),
                            );
                            setState(() {
                              loading = false;
                              description = '';
                              name = '';
                              needsVer = true;
                            });
                          } else {
                            setState(() {
                              error = 'Choose at least 1 photo';
                            });
                          }
                        }
                      },
                      color: darkPrimaryColor,
                      textColor: whiteColor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        error,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
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
