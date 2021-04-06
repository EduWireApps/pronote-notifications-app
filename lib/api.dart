import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pronote_notifications/firebase.dart';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;

class UserData {
  // informations
  String fullName;
  String studentClass;
  String avatarBase64;
  String establishment;

  // settings
  bool notificationsHomeworks;
  bool notificationsMarks;

  UserData(this.fullName, this.establishment, this.studentClass,
      this.avatarBase64, this.notificationsHomeworks, this.notificationsMarks);
}

class NotificationData {
  String type;
  String title;
  bool hasSmallBody;
  String smallBody;
  String body;

  NotificationData(
      this.type, this.title, this.hasSmallBody, this.smallBody, this.body);
}

class EstablishmentData {
  String name;
  String url;

  EstablishmentData(this.name, this.url);
}

// Get the application information, including the platform and the version
PackageInfo packageInfo;
Future<String> getApplicationVersion() async {
  if (packageInfo == null) {
    packageInfo = await PackageInfo.fromPlatform();
  }
  return (Platform.isAndroid ? 'android-' : 'ios-') + packageInfo.version;
}

const API_URL = 'pnotifications.atlanta-bot.fr';

// Implements all the API requests
class API {
  static Future<bool> isLogged() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final logged = sharedPreferences.getBool('logged') ?? false;
    return logged;
  }

  static Future<UserData> register(
      String username, String password, String pronoteURL) async {
    final fcmToken = await getDeviceToken();
    final response = await http.post(
      Uri.https(API_URL, "register"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'App-Version': await getApplicationVersion()
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
      return new UserData(
          jsonData['full_name'],
          jsonData['establishment'],
          jsonData['student_class'],
          jsonData['avatar_base64'],
          jsonData['notifications_homeworks'],
          jsonData['notifications_marks']);
    }
  }

  static Future<UserData> login() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('jwt');
    final response =
        await http.get(Uri.https(API_URL, "login"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
      'App-Version': await getApplicationVersion()
    });
    final jsonData = json.decode(response.body);
    if (!jsonData['success']) {
      throw (jsonData['message']);
    } else {
      return new UserData(
          jsonData['full_name'],
          jsonData['establishment'],
          jsonData['student_class'],
          jsonData['avatar_base64'],
          jsonData['notifications_homeworks'],
          jsonData['notifications_marks']);
    }
  }

  static Future<void> updateSettings(
      bool notificationsHomeworks, bool notificationsMarks) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('jwt');
    await http.post(
      Uri.https(API_URL, "settings"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
        'App-Version': await getApplicationVersion()
      },
      body: jsonEncode({
        'notifications_homeworks': notificationsHomeworks.toString(),
        'notifications_marks': notificationsMarks.toString()
      }),
    );
    return;
  }

  static Future<void> logout() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('jwt');
    await http.post(Uri.https(API_URL, "logout"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
      'App-Version': await getApplicationVersion()
    });
    sharedPreferences.setBool('logged', false);
    sharedPreferences.remove('jwt');
  }

  static Future<List<dynamic>> getUserNotifications() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('jwt');
    final response = await http
        .get(Uri.https(API_URL, "notifications"), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
      'App-Version': await getApplicationVersion()
    });
    final jsonData = json.decode(response.body);
    if (!jsonData['success']) {
      throw (jsonData['message']);
    } else {
      return jsonData['notifications']
          .map((notificationData) => NotificationData(
              notificationData['type'],
              notificationData['title'],
              notificationData['body'].length > 30,
              notificationData['body'].length > 30
                  ? notificationData['body'].substring(0, 30) + "..."
                  : null,
              notificationData['body']))
          .toList();
    }
  }

  static Future<List<dynamic>> getEstablishments(latitude, longitude) async {
    var jsonData;
    try {
      final response = await http.get(
          Uri.https('pnotifications.atlanta-bot.fr', 'establishments', {
            'latitude': latitude.toString(),
            'longitude': longitude.toString()
          }),
          headers: {'App-Version': await getApplicationVersion()});
      jsonData = json.decode(response.body);
    } catch (e) {
      throw 'Impossible de se connecter au serveur';
    }
    if (!jsonData['success']) {
      throw (jsonData['message']);
    } else {
      if (jsonData['establishments'].length == 0) {
        throw 'Aucun établissement trouvé...';
      } else {
        return jsonData['establishments']
            .map((establishmentData) => EstablishmentData(
                establishmentData['nomEtab'], establishmentData['url']))
            .toList();
      }
    }
  }
}
