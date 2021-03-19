import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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

	FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("onMessage: $message");
    if (message.data['type'] != null) showNotification(message);
  });
}

showNotification(RemoteMessage notificationData) async {
    final title = notificationData.notification.title;
    final body = notificationData.notification.body;
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
