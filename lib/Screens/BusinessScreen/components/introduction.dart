import 'package:animate_do/animate_do.dart';
import 'package:easark/Screens/BusinessScreen/components/add_place1.dart';
import 'package:easark/Screens/HomeScreen/home_screen.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);
  @override
  _IntroductionScreenScreenState createState() =>
      _IntroductionScreenScreenState();
}

class _IntroductionScreenScreenState extends State<IntroductionScreen> {
  bool isAgreed = false;

  Color getColor(Set<MaterialState> states) {
    return darkColor;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1.0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1.0),
        iconTheme: const IconThemeData(
          color: darkDarkColor,
        ),
        title: Text(
          'Info',
          textScaleFactor: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
                color: darkColor, fontSize: 20, fontWeight: FontWeight.w300),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Image.asset(
                      'assets/images/car_down.png',
                      fit: BoxFit.fitWidth,
                      width: size.width * 0.5 - 20,
                    ),
                  ),
                  FadeInRight(
                    child: LimitedBox(
                      maxWidth: size.width * 0.5 - 20,
                      child: Text(
                        Languages.of(context)!.businessScreentext1,
                        maxLines: 1000,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: darkColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInLeft(
                    delay: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/2.png',
                      fit: BoxFit.fitWidth,
                      width: size.width * 0.7 - 20,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FadeInUp(
                    delay: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/3.png',
                      fit: BoxFit.fitWidth,
                      width: size.width * 0.2 - 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInLeft(
                    delay: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/2.png',
                      fit: BoxFit.fitWidth,
                      width: size.width * 0.7 - 20,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FadeInUp(
                    delay: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/3.png',
                      fit: BoxFit.fitWidth,
                      width: size.width * 0.2 - 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              FadeInUp(
                delay: const Duration(seconds: 2),
                child: LimitedBox(
                  maxWidth: size.width * 0.9 - 20,
                  child: Text(
                    Languages.of(context)!.businessScreentext2,
                    maxLines: 1000,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        color: darkColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                      checkColor: whiteColor,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: isAgreed,
                      onChanged: (bool? value) {
                        setState(() {
                          isAgreed = value!;
                        });
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  LimitedBox(
                    maxWidth: size.width * 0.7 - 20,
                    child: Text(
                      Languages.of(context)!.loginScreenPolicy,
                      maxLines: 1000,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          color: darkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              RoundedButton(
                width: 0.6,
                ph: 45,
                text: 'GET STARTED',
                press: () async {
                  if (isAgreed) {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: const AddPlaceScreen(),
                      ),
                    );
                  }
                },
                color: darkPrimaryColor,
                textColor: whiteColor,
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
