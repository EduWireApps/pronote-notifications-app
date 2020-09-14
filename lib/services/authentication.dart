import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {

    Future<bool> isLogged();
    Future<String> getCurrentUser();
    Future<void> signOut();
    Future<String> signIn(String username, String password, String pronoteURL);

}

class Auth implements BaseAuth {

    Future<SharedPreferences> getInstance() async {
        return await SharedPreferences.getInstance();
    }

    Future<bool> isLogged() async {
        final logged = (await getInstance()).getBool('logged') ?? false;
        return logged;
    }

    Future<String> getCurrentUser() async {
        final logged = await isLogged();
        if (!logged) return null;
        final userName = (await getInstance()).getString('username');
        return userName;
    }

    Future<void> signOut() async {
        (await getInstance()).setBool('logged', false);
    }

    Future<String> signIn(String username, String password, String pronoteURL) async {
        final response = await http.post(
            'https://fba7e5a843b2.ngrok.io/',
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
                'username': username,
                'password': password,
                'pronote_url': pronoteURL
            }),
        );
        final jsonData = json.decode(response.body);
        if (!jsonData['success']) {
            throw (jsonData['message']);
        } else {
            (await getInstance()).setBool('logged', true);
            (await getInstance()).setString('username', jsonData['name']);
            return jsonData['name'];
        }
    }

}
