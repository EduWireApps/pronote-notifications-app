import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
    String fullName;
    String studentClass;
    String avatarBase64;

    bool notificationsHomeworks;
    bool notificationsMarks;

    UserData(this.fullName, this.studentClass, this.avatarBase64, this.notificationsHomeworks, this.notificationsMarks);
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

    Future<SharedPreferences> getInstance() async {
        return await SharedPreferences.getInstance();
    }

    Future<bool> isLogged() async {
        final logged = (await getInstance()).getBool('logged') ?? false;
        return logged;
    }

    Future<void> logout() async {
        (await getInstance()).setBool('logged', false);
        (await getInstance()).setString('jwt', null);
    }

    Future<UserData> login() async {
        final shared = await this.getInstance();
        final response = await callAPI('login');
        final jsonData = json.decode(response.body);
        if (!jsonData['success']) {
            throw (jsonData['message']);
        } else {
            return new UserData(jsonData['full_name'], jsonData['student_class'], jsonData['avatar_base64'], jsonData['notifications_homeworks'], jsonData['notifications_marks']);
        }
    }

    Future<void> updateSettings (bool notificationsHomeworks, bool notificationsMarks) async {
        final response = await callAPI('settings', {
            'notifications_homeworks': notificationsHomeworks.toString(),
            'notifications_marks': notificationsMarks.toString()
        });
        return;
    }

    Future<UserData> register(String username, String password, String pronoteURL) async {
        final response = await http.post(
            "https://3fca5b61feaf.ngrok.io/register",
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
                'pronote_username': username,
                'pronote_password': password,
                'pronote_url': pronoteURL,
                'fcm_token': (await getInstance()).getString('fcm-token')
            }),
        );
        final jsonData = json.decode(response.body);
        if (!jsonData['success']) {
            throw (jsonData['message']);
        } else {
            final instance = await getInstance();
            instance.setBool('logged', true);
            instance.setString('jwt', jsonData['jwt']);
            return new UserData(jsonData['full_name'], jsonData['student_class'], jsonData['avatar_base64'], jsonData['notifications_homeworks'], jsonData['notifications_marks']);
        }
    }

    Future<http.Response> callAPI (String route, [Object body]) async {
        final token = (await getInstance()).getString('jwt');
        final response = await http.post(
            "https://3fca5b61feaf.ngrok.io/$route",
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token
            },
            body: jsonEncode(body ?? {}),
        );
        return response;
    }

}
