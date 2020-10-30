import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
final initializationSettingsIOS = IOSInitializationSettings();
final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

bool _initialized = false;

void initFirebase()
{
  if (_initialized) {
    return;
  }

  _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  _initialized = true;

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
      if (message['data']['type'] != null) showNotification(message);
    },
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
    },
    onResume: (Map<String, dynamic> message) async {
      // {notification: {}, data: {collapse_key: com.litarvan.epilyon, color: #ff0000, google.original_priority: high, google.sent_time: 1581341404242, google.delivered_priority: high, google.ttl: 2419200, from: 472301904711, id: 1, click_action: FLUTTER_NOTIFICATION_CLICK, google.message_id: 0:1581341404252844%4fecd5444fecd544, status: done}}
      print("onResume: $message");
    },
  );
}

showNotification(Map<String, dynamic> notificationData) async {
    final title = notificationData['notification']['title'];
    final body = notificationData['notification']['body'];
    final android = new AndroidNotificationDetails(title, title, title, styleInformation: BigTextStyleInformation(''));
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
