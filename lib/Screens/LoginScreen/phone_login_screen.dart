import 'package:easark/Models/LanguageData.dart';
import 'package:easark/Models/PushNotificationMessage.dart';
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
import 'package:overlay_support/overlay_support.dart';

import 'login_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  final String errors;
  const PhoneLoginScreen({Key? key, this.errors = ''}) : super(key: key);
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
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
                  SizedBox(
                    height: !codeSent ? 100 : 0,
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
                                  ? SizedBox(
                                      width: size.width * 0.7,
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: darkDarkColor),
                                        validator: (val) => val!.isEmpty
                                            ? 'Enter a code'
                                            : null,
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) {
                                          setState(() {
                                            smsCode = val;
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
                                          hintText: 'Code',
                                          border: InputBorder.none,
                                        ),
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
                                      try {
                                        UserCredential res = await AuthService()
                                            .signInWithOTP(smsCode,
                                                verificationId, context);
                                        if(res != null){
                                          Navigator.of(context).pop();
                                        }
                                        
                                      } catch (e) {
                                        setState(() {
                                          // error = 'Enter valid data';
                                          loading = false;
                                        });
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Fail',
                                          body: 'Wrong code',
                                        );
                                        showSimpleNotification(
                                          Text(notification.body),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      }
                                      // setState(() {
                                      //     // error = 'Enter valid data';
                                      //     loading = false;
                                      //   });
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
                                                page:
                                                    const PhoneLoginScreen()));
                                      },
                                      color: lightPrimaryColor,
                                      textColor: whiteColor,
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
