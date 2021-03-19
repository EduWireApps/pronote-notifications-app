import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pronote_notifications/firebase.dart';

class UserData {

  // informations
	String fullName;
	String studentClass;
	String avatarBase64;
	String establishment;

  // settings
	bool notificationsHomeworks;
	bool notificationsMarks;
	
	UserData(this.fullName, this.establishment, this.studentClass, this.avatarBase64, this.notificationsHomeworks, this.notificationsMarks);
}

class NotificationData {

	String type;
	String title;
	bool hasSmallBody;
	String smallBody;
	String body;

	NotificationData(this.type, this.title, this.hasSmallBody, this.smallBody, this.body);
}

abstract class BaseAPI {

  // to get login status
	Future<bool> isLogged();
	// to register at the beginning
	Future<UserData> register(String username, String password, String pronoteURL);
  // to login and get informations about the current user
	Future<UserData> login();
	// to update settings
	Future<void> updateSettings(bool notificationsHomeworks, bool notificationsMarks);
	// to logout
	Future<void> logout();
	// to get notifications
	Future<List<dynamic>> getUserNotifications();

}

class API implements BaseAPI {

	Future<bool> isLogged() async {
		final sharedPreferences = await SharedPreferences.getInstance();
		final logged = sharedPreferences.getBool('logged') ?? false;
		return logged;
	}

	Future<UserData> register(String username, String password, String pronoteURL) async {
		final fcmToken = await getDeviceToken();
		final response = await http.post(
			Uri.https("https://pnotifications.atlanta-bot.fr", "register"),
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
			},
			body: jsonEncode(<String, String>{
				'pronote_username': username,
				'pronote_password': password,
				'pronote_url': pronoteURL,
				'fcm_token': fcmToken
			}),
		);
		final jsonData = json.decode(response.body);
		if (!jsonData['success']) {
			throw (jsonData['message']);
		} else {
			final sharedPreferences = await SharedPreferences.getInstance();
			sharedPreferences.setBool('logged', true);
			sharedPreferences.setString('jwt', jsonData['jwt']);
			sharedPreferences.setString('form_pronote_username', username);
			sharedPreferences.setString('form_pronote_url', pronoteURL);
			sharedPreferences.setString('jwt', jsonData['jwt']);
			return new UserData(jsonData['full_name'], jsonData['establishment'], jsonData['student_class'], jsonData['avatar_base64'], jsonData['notifications_homeworks'], jsonData['notifications_marks']);
		}
	}

	Future<UserData> login() async {
		final sharedPreferences = await SharedPreferences.getInstance();
		final token = sharedPreferences.getString('jwt');
		final response = await http.get(
			Uri.https("https://pnotifications.atlanta-bot.fr", "login"),
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
				'Authorization': token
			}
		);
		final jsonData = json.decode(response.body);
		if (!jsonData['success']) {
			throw (jsonData['message']);
		} else {
			return new UserData(jsonData['full_name'], jsonData['establishment'], jsonData['student_class'], jsonData['avatar_base64'], jsonData['notifications_homeworks'], jsonData['notifications_marks']);
		}
	}

	Future<void> updateSettings (bool notificationsHomeworks, bool notificationsMarks) async {
		final sharedPreferences = await SharedPreferences.getInstance();
		final token = sharedPreferences.getString('jwt');
		await http.post(
			Uri.https("https://pnotifications.atlanta-bot.fr", "settings"),
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
				'Authorization': token
			},
			body: jsonEncode({
				'notifications_homeworks': notificationsHomeworks.toString(),
				'notifications_marks': notificationsMarks.toString()
			}),
		);
		return;
	}

	Future<void> logout() async {
		final sharedPreferences = await SharedPreferences.getInstance();
		final token = sharedPreferences.getString('jwt');
		await http.post(
			Uri.https("https://pnotifications.atlanta-bot.fr", "logout"),
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
				'Authorization': token
			}
		);
		sharedPreferences.setBool('logged', false);
		sharedPreferences.remove('jwt');
	}

	Future<List<dynamic>> getUserNotifications() async {
		final sharedPreferences = await SharedPreferences.getInstance();
		final token = sharedPreferences.getString('jwt');
		final response = await http.get(
			Uri.https("https://pnotifications.atlanta-bot.fr", "notifications"),
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
				'Authorization': token
			}
		);
		final jsonData = json.decode(response.body);
		if (!jsonData['success']) {
			throw (jsonData['message']);
		} else {
			return jsonData['notifications'].map((notificationData) => NotificationData(
				notificationData['type'], notificationData['title'], notificationData['body'].length > 30, notificationData['body'].length > 30 ?  notificationData['body'].substring(0, 30)+"..." : null, notificationData['body']
			)).toList();
		}
	}
}
