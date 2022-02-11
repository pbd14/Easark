import 'package:csc_picker/csc_picker.dart';
import 'package:easark/Models/LanguageData.dart';
import 'package:easark/Screens/LoginScreen/email_login_screen.dart';
import 'package:easark/Screens/LoginScreen/email_signup_screen.dart';
import 'package:easark/Screens/LoginScreen/phone_login_screen.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Services/languages/locale_constant.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final String errors;
  const LoginScreen({Key? key, this.errors = ''}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late String verificationId;
  String error = '';
  String? country;
  String? state;
  String? city;
  bool loading = false;

  // Future<void> checkVersion() async {
  //   RemoteConfig remoteConfig = RemoteConfig.instance;
  //   // ignore: unused_local_variable
  //   bool updated = await remoteConfig.fetchAndActivate();
  //   String requiredVersion = remoteConfig.getString(Platform.isAndroid
  //       ? 'footy_google_play_version'
  //       : 'footy_appstore_version');
  //   String appStoreLink = remoteConfig.getString('footy_appstore_link');
  //   String googlePlayLink = remoteConfig.getString('footy_google_play_link');

  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   if (packageInfo.version != requiredVersion) {
  //     NativeUpdater.displayUpdateAlert(
  //       context,
  //       forceUpdate: true,
  //       appStoreUrl: appStoreLink,
  //       playStoreUrl: googlePlayLink,
  //     );
  //   }
  // }

  @override
  void initState() {
    // checkVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            backgroundColor: const Color.fromRGBO(247, 247, 247, 1.0),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                  ),
                  Text(
                    Languages.of(context)!.welcomeToEasark,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        color: darkColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                  SizedBox(
                    width: size.width * 0.8,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Language',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: darkColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButton<LanguageData>(
                              iconSize: 30,
                              hint: Text(
                                  Languages.of(context)!.labelSelectLanguage),
                              onChanged: (LanguageData? language) {
                                changeLanguage(context, language!.languageCode);
                              },
                              items: LanguageData.languageList()
                                  .map<DropdownMenuItem<LanguageData>>(
                                    (e) => DropdownMenuItem<LanguageData>(
                                      value: e,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(
                                            e.flag,
                                            style:
                                                const TextStyle(fontSize: 30),
                                          ),
                                          Text(e.name)
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/images/login1.png',
                        height: 300,
                        width: size.width * 0.9,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                        top: 200,
                        child: SizedBox(
                          width: size.width * 0.8,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Languages.of(context)!.loginScreen1head,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    Languages.of(context)!.loginScreen1text,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/images/login2.png',
                        height: 200,
                        width: size.width * 0.9,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                        top: 170,
                        child: SizedBox(
                          width: size.width * 0.8,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Languages.of(context)!.loginScreen2head,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    Languages.of(context)!.loginScreen2text,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/images/login3.png',
                        height: 200,
                        width: size.width * 0.9,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                        top: 165,
                        child: SizedBox(
                          width: size.width * 0.8,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Languages.of(context)!.loginScreen3head,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    Languages.of(context)!.loginScreen3text,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: darkColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  Center(
                    child: SizedBox(
                      width: size.width * 0.9,
                      child: Card(
                        elevation: 10,
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 40,
                              ),
                              Text(
                                Languages.of(context)!.getStarted,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              SizedBox(
                                width: size.width * 0.7,
                                child: CSCPicker(
                                  flagState: CountryFlag.DISABLE,
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
                              ),

                              const SizedBox(
                                height: 100,
                              ),

                              RoundedButton(
                                pw: 250,
                                ph: 45,
                                text: 'Enter with Phone',
                                press: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (country != null &&
                                        city != null &&
                                        state != null &&
                                        country!.isNotEmpty &&
                                        state!.isNotEmpty &&
                                        city!.isNotEmpty) {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: const PhoneLoginScreen(),
                                        ),
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                    } else {
                                      setState(() {
                                        error =
                                            'Please choose your city state and country';
                                      });
                                    }
                                  }
                                },
                                color: darkPrimaryColor,
                                textColor: whiteColor,
                              ),

                              const SizedBox(
                                height: 50,
                              ),
                              RoundedButton(
                                pw: 250,
                                ph: 45,
                                text: 'Login with Email',
                                press: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (country != null &&
                                        city != null &&
                                        state != null &&
                                        country!.isNotEmpty &&
                                        state!.isNotEmpty &&
                                        city!.isNotEmpty) {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: const EmailLoginScreen(),
                                        ),
                                      );

                                      setState(() {
                                        loading = false;
                                      });
                                    } else {
                                      setState(() {
                                        error =
                                            'Please choose your city state and country';
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
                              RoundedButton(
                                pw: 250,
                                ph: 45,
                                text: 'Sign Up with Email',
                                press: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (country != null &&
                                        city != null &&
                                        state != null &&
                                        country!.isNotEmpty &&
                                        state!.isNotEmpty &&
                                        city!.isNotEmpty) {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: const EmailSignUpScreen(),
                                        ),
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                    } else {
                                      setState(() {
                                        error =
                                            'Please choose your city state and country';
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
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.05, 0, size.width * 0.05, 0),
                                child: Text(
                                  Languages.of(context)!.loginScreenPolicy,
                                  textScaleFactor: 1,
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              // RoundedButton(
                              //   text: 'REGISTER',
                              //   press: () {
                              //     Navigator.push(
                              //         context, SlideRightRoute(page: RegisterScreen()));
                              //   },
                              //   color: lightPrimaryColor,
                              //   textColor: darkPrimaryColor,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
