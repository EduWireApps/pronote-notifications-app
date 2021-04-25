import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pronote_notifications/pages/notifications.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');
final initializationSettingsIOS = IOSInitializationSettings();
final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

bool _initialized = false;

void initFirebase(GlobalKey<NavigatorState> navigatorKey) {
  if (_initialized) {
    return;
  }

  Firebase.initializeApp();

  void handleSelectNotification () async {
    if (await LaunchApp.isAppInstalled(androidPackageName: 'com.IndexEducation.Pronote', iosUrlScheme: 'pronote://') != 0) {
        print('Launching Pronote...');
        LaunchApp.openApp(androidPackageName: 'com.IndexEducation.Pronote', iosUrlScheme: 'pronote://');
      } else {
        print('Pronote is not installed...');
        navigatorKey.currentState
          .push(MaterialPageRoute(builder: (context) => NotificationsPage()));
      }
  }

  Future<void> onSelectNotification (String payload) {
    handleSelectNotification();
    return null;
  }

  _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  _initialized = true;

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("message received from Firebase Messaging");
    if (message.data['type'] != null) showNotification(message.notification.title, message.notification.body);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("notification clicked by the user");
    if (message.data['type'] != null) handleSelectNotification();
  });
}

showNotification(String title, String body) async {
  final android = new AndroidNotificationDetails(title, title, title,
      styleInformation: BigTextStyleInformation(''));
  final iOS = new IOSNotificationDetails();
  final platform = new NotificationDetails(android: android, iOS: iOS);
  await _flutterLocalNotificationsPlugin.show(0, title, body, platform);
}

Future<String> getDeviceToken() async {
  try {
    return await _firebaseMessaging.getToken();
  } catch (e) {
    print('Error while getting device token');
    print(e);
    return "nope";
  }
}
