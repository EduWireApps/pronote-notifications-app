import 'package:flutter/material.dart';
import 'package:pronote_notifications/pages/login.dart';
import 'package:pronote_notifications/api.dart';
import 'package:pronote_notifications/pages/home.dart';
import 'package:pronote_notifications/firebase.dart';
import 'package:pronote_notifications/widgets/dialogs.dart';

enum AuthStatus {
	NOT_DETERMINED,
	NOT_LOGGED_IN,
	LOGGED_IN,
}

class RootPage extends StatefulWidget {
	RootPage({this.api});

	final BaseAPI api;

	@override
	State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
	AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
	UserData _userData;

	@override
	void initState() {
		super.initState();
		initFirebase();

		widget.api.isLogged().then((isLogged) {
			if (!isLogged) {
				setState(() {
					authStatus = AuthStatus.NOT_LOGGED_IN;
				});
			} else {
				try {
					widget.api.login().then((userData) {
						setState(() {
							_userData = userData;
							authStatus = AuthStatus.LOGGED_IN;
						});
					});
				} catch (e) {
					print('Error: $e');
					if (e is String) {
						setState(() {
							showInfoDialog(context, title: 'Une erreur est survenue', content: e);
						});
					} else {
						if (e.message == null) showInfoDialog(context, title: 'Une erreur est survenue', content: 'Quelque chose s\'est mal passé durant la connexion...');
						setState(() {
							if (e.message.contains('Unexpected character')) {
								showInfoDialog(context, title: 'Une erreur est survenue', content: 'Le serveur de Notifications pour Pronote est actuellement injoignable. Merci de patienter puis réessayez !');
							} else {
								setState(() {
									authStatus = AuthStatus.NOT_LOGGED_IN;
								});
							}
						});
					}
				}
			}
		});
	}

	void loginCallback(UserData userData) {
			setState(() {
				_userData = userData;
				authStatus = AuthStatus.LOGGED_IN;
			});
	}

	void logoutCallback() {
		setState(() {
			authStatus = AuthStatus.NOT_LOGGED_IN;
			_userData = null;
		});
	}

	Widget buildWaitingScreen() {
		return Scaffold(
			body: Container(
				alignment: Alignment.center,
				child: CircularProgressIndicator(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		switch (authStatus) {
		case AuthStatus.NOT_DETERMINED:
			return buildWaitingScreen();
			break;
		case AuthStatus.NOT_LOGGED_IN:
			return new LoginPage(
				api: widget.api,
				loginCallback: loginCallback,
			);
			break;
		case AuthStatus.LOGGED_IN:
			if (_userData != null) {
				return new HomePage(
					userData: _userData,
					api: widget.api,
					logoutCallback: logoutCallback,
				);
			} else return buildWaitingScreen();
			break;
		default:
			return buildWaitingScreen();
		}
	}
}