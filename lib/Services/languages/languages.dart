import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get welcomeToEasark;
  String get labelSelectLanguage;
  String get loginScreen1head;
  String get loginScreen1text;
  String get loginScreen2head;
  String get loginScreen2text;
  String get loginScreen3head;
  String get loginScreen3text;
  String get getStarted;
  String get loginScreenYourPhone;
  String get loginScreen6Digits;
  String get loginScreenEnterCode;
  String get loginScreenReenterPhone;
  String get loginScreenPolicy;
  String get loginScreenCodeIsNotValid;

  String get mapScreenSearchHere;
  String get mapScreenLoadingMap;

  String get businessScreentext1;
  String get businessScreentext2;
}
