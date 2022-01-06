import 'package:easark/Models/LanguageData.dart';
import 'package:easark/Services/auth_service.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Services/languages/locale_constant.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  late String phoneNo;
  late String smsCode;
  late String verificationId;
  String error = '';

  bool codeSent = false;
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
            backgroundColor: darkPrimaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                  ),
                  Text(
                    Languages.of(context)!.welcomeToFooty,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        color: whiteColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: !codeSent ? 100 : 0,
                  ),
                  !codeSent
                      ? SizedBox(
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
                                    hint: Text(Languages.of(context)!
                                        .labelSelectLanguage),
                                    onChanged: (LanguageData? language) {
                                      changeLanguage(
                                          context, language!.languageCode);
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
                                                  style: const TextStyle(
                                                      fontSize: 30),
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
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 100 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature1.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)!
                                              .loginScreen1head,
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
                                          Languages.of(context)!
                                              .loginScreen1text,
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
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 200 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature2.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)!
                                              .loginScreen2head,
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
                                          Languages.of(context)!
                                              .loginScreen2text,
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
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 200 : 0,
                  ),
                  !codeSent
                      ? Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/nature3.jpg',
                              height: 200,
                              width: size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 120,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Languages.of(context)!
                                              .loginScreen3head,
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
                                          Languages.of(context)!
                                              .loginScreen3text,
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
                        )
                      : Container(),
                  SizedBox(
                    height: !codeSent ? 150 : 50,
                  ),
                  Center(
                    child: SizedBox(
                      width: size.width * 0.95,
                      child: Card(
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
                              const SizedBox(height: 30),
                              !codeSent
                                  ? SizedBox(
                                      width: size.width * 0.7,
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: darkDarkColor),
                                        validator: (val) => val!.isEmpty
                                            ? 'Enter a phone number'
                                            : null,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (val) {
                                          setState(() {
                                            phoneNo = val;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: darkColor, width: 1.0),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: darkColor, width: 1.0),
                                          ),
                                          hintStyle: TextStyle(
                                              color:
                                                  darkColor.withOpacity(0.7)),
                                          hintText: 'Phone',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? TextFormField(
                                      style:
                                          const TextStyle(color: darkDarkColor),
                                      validator: (val) =>
                                          val!.isEmpty ? 'Enter a code' : null,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (val) {
                                        setState(() {
                                          smsCode = val;
                                        });
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
                                        hintText: 'Code',
                                        border: InputBorder.none,
                                      ),
                                    )
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? const SizedBox(height: 20)
                                  : SizedBox(height: size.height * 0),

                              // RoundedPasswordField(
                              //   hintText: "Password",
                              //   onChanged: (value) {},
                              // ),
                              const SizedBox(height: 20),
                              RoundedButton(
                                width: 0.4,
                                ph: 45,
                                text: 'GO',
                                press: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    if (codeSent) {
                                      dynamic res = await AuthService()
                                          .signInWithOTP(
                                              smsCode, verificationId, context);
                                      if (res == null) {
                                        setState(() {
                                          // error = 'Enter valid data';
                                          loading = false;
                                        });
                                      }
                                    } else {
                                      await verifyPhone(phoneNo);
                                    }
                                  }
                                },
                                color: darkPrimaryColor,
                                textColor: whiteColor,
                              ),
                              codeSent
                                  ? const SizedBox(height: 55)
                                  : SizedBox(height: size.height * 0),
                              codeSent
                                  ? RoundedButton(
                                      width: 0.6,
                                      ph: 45,
                                      text: Languages.of(context)!
                                          .loginScreenReenterPhone,
                                      press: () {
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                                page: const LoginScreen()));
                                      },
                                      color: lightPrimaryColor,
                                      textColor: darkPrimaryColor,
                                    )
                                  : SizedBox(height: size.height * 0),
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

  verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (PhoneAuthCredential authResult) {
      AuthService().signIn(authResult, context);
      setState(() {
        loading = false;
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        error = '${authException.message}';
        loading = false;
      });
    };

    final PhoneCodeSent smsSent = (String verId, int? forceResend) {
      verificationId = verId;
      setState(() {
        error = '';
        codeSent = true;
        loading = false;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      verificationId = verId;
      if (mounted) {
        setState(() {
          codeSent = false;
          loading = false;
          error = Languages.of(context)!.loginScreenCodeIsNotValid;
        });
      }
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 100),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
