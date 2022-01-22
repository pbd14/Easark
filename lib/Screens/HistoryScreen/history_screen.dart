import 'package:easark/Screens/HistoryScreen/components/1.dart';
import 'package:easark/Services/languages/languages.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/2.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? stext;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                backgroundColor: darkColor,
                centerTitle: true,
                title: TabBar(
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(
                      child: Text(
                        Languages.of(context)!.historyScreenSchedule,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        Languages.of(context)!.historyScreenHistory,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  History1(),
                  History2(),
                ],
              ),
            ),
          );
  }
}
