import 'package:easark/Screens/HomeScreen/home_screen.dart';
import 'package:easark/Services/auth_service.dart';
import 'package:easark/Services/languages/applocalizationsdelegate.dart';
import 'package:easark/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Services/languages/locale_constant.dart';
import 'firebase_options.dart';

// com.easark
// SHA1: 19:15:92:FA:6D:EE:79:89:88:63:7A:59:5C:45:75:83:30:26:74:33
// SHA-256: 33:88:C5:61:62:CC:38:A9:CC:FE:3A:37:0A:17:70:2C:4F:86:BF:47:4B:6A:75:DF:3C:88:AD:0D:8D:07:E5:5A

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        routes: {
          Routes.businessScreen: (BuildContext context) => HomeScreen(
                tabNum: 1,
              ),
        },
        debugShowCheckedModeBanner: false,
        title: 'Easark',
        locale: _locale,
        theme: ThemeData(
            primaryColor: primaryColor, scaffoldBackgroundColor: whiteColor),
        home: AuthService().handleAuth(),
        supportedLocales: const [
          Locale('en', ''),
          Locale('ru', ''),
          Locale('uz', ''),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}

class Routes {
  static const String businessScreen = '/businessScreen';
}
