import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pronote_notifications/pages/root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MyApp());
}

Map<int, Color> color =
{
  50:Color.fromRGBO(41, 130, 108, .1),
  100:Color.fromRGBO(41, 130, 108, .2),
  200:Color.fromRGBO(41, 130, 108, .3),
  300:Color.fromRGBO(41, 130, 108, .4),
  400:Color.fromRGBO(41, 130, 108, .5),
  500:Color.fromRGBO(41, 130, 108, .6),
  600:Color.fromRGBO(41, 130, 108, .7),
  700:Color.fromRGBO(41, 130, 108, .8),
  800:Color.fromRGBO(41, 130, 108, .9),
  900:Color.fromRGBO(41, 130, 108, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF29826c, color);

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String textValue = 'Hello World !';
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails();
    await flutterLocalNotificationsPlugin.show(
        0, "This is title", "this is demo", platform);
  }

  update(String token) async {
    await (await SharedPreferences.getInstance()).setString('fcm-token', token);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Pronote Notifications',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: colorCustom,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
