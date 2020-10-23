import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
    String fullName;
    String studentClass;
    String avatarBase64;
    String establishment;

    bool notificationsHomeworks;
    bool notificationsMarks;

    UserData(this.fullName, this.establishment, this.studentClass, this.avatarBase64, this.notificationsHomeworks, this.notificationsMarks);
}

abstract class BaseAuth {

    // pour savoir rapidement si l'utilisateur est connecté ou non
    Future<bool> isLogged();
    // pour se connecter et récupérer les informations concernant un utilisateur
    Future<UserData> login();
    // pour se déconnecter de l'application
    Future<void> logout();
    // pour s'enregistrer (au démarrage). Similaire au login() mais le serveur test la connexion à Pronote en +
    Future<UserData> register(String username, String password, String pronoteURL);
    // pour modifier les préférences
    Future<void> updateSettings(bool notificationsHomeworks, bool notificationsMarks);

}

class Auth implements BaseAuth {

    Future<bool> isLogged() async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final logged = sharedPreferences.getBool('logged') ?? false;
        return logged;
    }

    Future<void> logout() async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final token = sharedPreferences.getString('jwt');
        await http.post(
            "https://pnotifications.atlanta-bot.fr/logout",
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token
            }
        );
        sharedPreferences.setBool('logged', false);
        sharedPreferences.setString('jwt', null);
    }

    Future<UserData> login() async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final token = sharedPreferences.getString('jwt');
        final response = await http.get(
            "https://pnotifications.atlanta-bot.fr/login",
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
            "https://pnotifications.atlanta-bot.fr/settings",
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

    Future<UserData> register(String username, String password, String pronoteURL) async {
        final sharedPreferences = await SharedPreferences.getInstance();
        final response = await http.post(
            "https://pnotifications.atlanta-bot.fr/register",
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
                'pronote_username': username,
                'pronote_password': password,
                'pronote_url': pronoteURL,
                'fcm_token': sharedPreferences.getString('fcm-token')
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
}
