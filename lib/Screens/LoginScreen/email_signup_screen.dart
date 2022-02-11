import 'package:easark/Models/PushNotificationMessage.dart';
import 'package:easark/Services/auth_service.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

class EmailSignUpScreen extends StatefulWidget {
  final String errors;
  const EmailSignUpScreen({Key? key, this.errors = ''}) : super(key: key);
  @override
  _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late String email;
  late String password;
  late String password2;
  late String verificationId;
  String error = '';

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
                    height: 100,
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
                                'Sign up',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: size.width * 0.7,
                                child: TextFormField(
                                  style: const TextStyle(color: darkDarkColor),
                                  validator: (val) =>
                                      val!.isEmpty ? 'Enter your email' : null,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (val) {
                                    setState(() {
                                      email = val;
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
                                    hintText: 'Email',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: size.width * 0.7,
                                child: TextFormField(
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  style: const TextStyle(color: darkDarkColor),
                                  validator: (val) => val!.length >= 5
                                      ? null
                                      : 'Minimum 5 characters',
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: (val) {
                                    setState(() {
                                      password = val;
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
                                    hintText: 'Password',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: size.width * 0.7,
                                child: TextFormField(
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  style: const TextStyle(color: darkDarkColor),
                                  validator: (val) => val!.length >= 5
                                      ? null
                                      : 'Minimum 5 characters',
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: (val) {
                                    setState(() {
                                      password2 = val;
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
                                    hintText: 'Confirm password',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

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
                                    if (password == password2) {
                                      setState(() {
                                        loading = true;
                                      });
                                      String res = await AuthService()
                                          .signUpWithEmail(email, password);
                                      if (res == 'Success') {
                                        await FirebaseAuth.instance.currentUser!
                                            .sendEmailVerification();
                                        setState(() {
                                          loading = false;
                                          Navigator.of(context).pop();
                                        });
                                      } else {
                                        setState(() {
                                          loading = false;
                                          error = res;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        error = 'Passwords should match';
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
