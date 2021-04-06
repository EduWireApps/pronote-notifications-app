import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pronote_notifications/pages/root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MainApp());
}

Map<int, Color> color = {
  50: Color.fromRGBO(41, 130, 108, .1),
  100: Color.fromRGBO(41, 130, 108, .2),
  200: Color.fromRGBO(41, 130, 108, .3),
  300: Color.fromRGBO(41, 130, 108, .4),
  400: Color.fromRGBO(41, 130, 108, .5),
  500: Color.fromRGBO(41, 130, 108, .6),
  600: Color.fromRGBO(41, 130, 108, .7),
  700: Color.fromRGBO(41, 130, 108, .8),
  800: Color.fromRGBO(41, 130, 108, .9),
  900: Color.fromRGBO(41, 130, 108, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF29826c, color);

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "MainNavigator");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return new MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Notifications pour Pronote',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: colorCustom,
        ),
        home: new RootPage(navigatorKey: navigatorKey));
  }
}
