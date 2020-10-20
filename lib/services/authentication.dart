import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pronote_notifications/services/push_notifications.dart';

class UserData {
    String fullName;
    String studentClass;
    String avatarBase64;

    UserData(this.fullName, this.studentClass, this.avatarBase64);
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

}

class Auth implements BaseAuth {

    Future<SharedPreferences> getInstance() async {
        return await SharedPreferences.getInstance();
    }

    Future<bool> isLogged() async {
        var fcmToken = (await getInstance()).getString('fcm_token');
        if(fcmToken == null) {
            PushNotificationsManager().init();
            fcmToken = (await getInstance()).getString('fcm_token');
        }
        final logged = (await getInstance()).getBool('logged') ?? false;
        return logged;
    }

    Future<void> logout() async {
        (await getInstance()).setBool('logged', false);
    }

    Future<UserData> login() async {
        final instance = await this.getInstance();
        final username = instance.getString('username');
        final password = instance.getString('password');
        final pronoteURL = instance.getString('pronote_url');
        final response = await this.callAPI(username, password, pronoteURL, 'login');
        final jsonData = json.decode(response.body);
        if (!jsonData['success']) {
            throw (jsonData['message']);
        } else {
            print(jsonData['avatar_base64']);
            return new UserData(jsonData['full_name'], jsonData['student_class'], jsonData['avatar_base64']);
        }
    }

    Future<List> register(String username, String password, String pronoteURL) async {
        final response = await this.callAPI(username, password, pronoteURL, 'register');
        final jsonData = json.decode(response.body);
        if (!jsonData['success']) {
            throw (jsonData['message']);
        } else {
            final instance = await getInstance();
            instance.setBool('logged', true);
            instance.setString('username', username);
            instance.setString('password', password);
            instance.setString('pronote_url', pronoteURL);
            return new UserData(jsonData['full_name'], jsonData['student_class'], jsonData['avatar_base64']);
        }
    }



    Future<http.Response> callAPI (String username, String password, String pronoteURL, String authType) async {
        final response = await http.post(
            "https://3fca5b61feaf.ngrok.io/$authType",
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
        return response;
    }

}
