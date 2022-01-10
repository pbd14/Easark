import 'package:easark/Services/languages/languages.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingMapScreen extends StatefulWidget {
  const LoadingMapScreen({Key? key}) : super(key: key);
  @override
  _LoadingMapScreenState createState() => _LoadingMapScreenState();
}

class _LoadingMapScreenState extends State<LoadingMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: whiteColor,
          child: Center(
            child: Text(
              Languages.of(context)!.mapScreenLoadingMap,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
