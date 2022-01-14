import 'dart:convert';
import 'dart:io';
import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Screens/BusinessScreen/components/add_place2.dart';
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

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({
    Key? key,
  }) : super(key: key);
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  int? numberOfSpaces;
  int? ppm;
  bool? is24hours = false;
  String? description;
  String? currency = 'UZS';
  bool needsVer = false;
  bool? remoteConfigUpdated;
  String error = '';
  File? i1, i2, i3, i4, i5, i6;
  String? country;
  String? state;
  String? city;
  RemoteConfig remoteConfig = RemoteConfig.instance;

  String selectedDay = '';
  String? _hour, _minute, _time;
  String? _hour2, _minute2, _time2;
  // ignore: non_constant_identifier_names
  List<String> payment_methods = [];
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

  Future<void> prepare() async {
    remoteConfigUpdated = await remoteConfig.fetchAndActivate().then((value) {
      setState(() {
        currencies = jsonDecode(remoteConfig
            .getValue('available_currencies')
            .asString())['currencies'];
        loading = false;
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
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: darkPrimaryColor,
              iconTheme: const IconThemeData(
                color: whiteColor,
              ),
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
                          'Add new place',
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
                                  description = val;
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
                                  hintText: 'Description',
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                validator: (val) =>
                                    val!.isNotEmpty ? null : 'Minimum 1 number',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  numberOfSpaces = int.parse(val);
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
                                  hintText: 'Number of parking spaces',
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
                              Text(
                                'Price of the parking: ' +
                                    currency! +
                                    ' per minute',
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
                                onChanged: (val) {
                                  ppm = int.parse(val);
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
                                  hintText: 'Price of the parking: ' +
                                      currency! +
                                      ' per minute',
                                  border: InputBorder.none,
                                ),
                              ),

                              const SizedBox(height: 30),
                              CSCPicker(
                                defaultCountry: DefaultCountry.Uzbekistan,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Is it 24/7?',
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
                                      value: is24hours!,
                                      onChanged: (val) {
                                        if (mounted) {
                                          setState(() {
                                            is24hours = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              !is24hours!
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (mon['status'] != null) {
                                                  if (mon['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (tue['status'] != null) {
                                                  if (tue['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (wed['status'] != null) {
                                                  if (wed['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (thu['status'] != null) {
                                                  if (thu['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (fri['status'] != null) {
                                                  if (fri['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (sat['status'] != null) {
                                                  if (sat['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                                selectedTime = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                selectedTime2 = const TimeOfDay(
                                                    hour: 00, minute: 00);
                                                if (sun['status'] != null) {
                                                  if (sun['status'] == 'open') {
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
                                                            color: whiteColor,
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
                                  : Container(),
                              const SizedBox(height: 10),
                              !is24hours!
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
                                  : Container(),
                              const SizedBox(height: 10),
                              !is24hours!
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
                                                    const EdgeInsets.all(10),
                                                width: 70,
                                                height: 50,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                    color: lightPrimaryColor),
                                                child: TextFormField(
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  onSaved: (val) {},
                                                  enabled: false,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  controller: _timeController,
                                                  decoration:
                                                      const InputDecoration(
                                                          disabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          // labelText: 'Time',
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  5)),
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
                                                    const EdgeInsets.all(10),
                                                width: 70,
                                                height: 50,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                    color: lightPrimaryColor),
                                                child: TextFormField(
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  onSaved: (val) {},
                                                  enabled: false,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  controller: _timeController2,
                                                  decoration:
                                                      const InputDecoration(
                                                          disabledBorder:
                                                              UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                          // labelText: 'Time',
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  5)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
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
                                            ? const Icon(
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
                                            ? const Icon(
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
                                            ? const Icon(
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
                                            ? const Icon(
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
                                            ? const Icon(
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
                                            ? const Icon(
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
                              i6 != null) {
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
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: AddPlaceScreen2(
                                  data: {
                                    'number_of_spaces': numberOfSpaces,
                                    'description': description,
                                    'country': country,
                                    'state': state,
                                    'city': city,
                                    'needs_verification': needsVer,
                                    'currency': currency,
                                    'ppm': ppm,
                                    'is24/7': is24hours,
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
                                    'isActive': true,
                                    'images': [
                                      await a1?.ref.getDownloadURL(),
                                      await a2?.ref.getDownloadURL(),
                                      await a3?.ref.getDownloadURL(),
                                      await a4?.ref.getDownloadURL(),
                                      await a5?.ref.getDownloadURL(),
                                      await a6?.ref.getDownloadURL(),
                                    ],
                                    'owner_id':
                                        FirebaseAuth.instance.currentUser!.uid,
                                  },
                                ),
                              ),
                            );
                            setState(() {
                              loading = false;
                              numberOfSpaces = 0;
                              description = '';
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
                  ],
                ),
              ),
            ),
          );
  }
}
