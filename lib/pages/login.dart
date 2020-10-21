import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
	LoginPage({this.auth, this.loginCallback});

	final BaseAuth auth;
	final Function loginCallback;

	@override
	State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	final _formKey = new GlobalKey<FormState>();

	String _username;
	String _password;
	String _pronoteURL;
	String _errorMessage;

	bool _isLoading;

	// Check if form is valid before perform login or signup
	bool validateAndSave() {
		final form = _formKey.currentState;
		if (form.validate()) {
			form.save();
			return true;
		}
		return false;
	}

	// Perform login or signup
	void validateAndSubmit() async {
		setState(() {
			_errorMessage = "";
			_isLoading = true;
		});
		if (validateAndSave()) {
			/*try {
				final result = await InternetAddress.lookup('example.com');
				if (!(result.isNotEmpty && result[0].rawAddress.isNotEmpty)) {
					setState(() {
						_isLoading = false;
					});
					showErrorDialog('Aucune connexion', 'Accès à Internet impossible, veuillez vérifier votre connexion.');
					return;
				}
			} on SocketException catch (_) {
				setState(() {
					_isLoading = false;
				});
				showErrorDialog('Aucune connexion', 'Accès à Internet impossible, veuillez vérifier votre connexion.');
				return;
			}*/
			try {
				final userData = await widget.auth.register(_username, _password, _pronoteURL);
				print('Signed in: ${userData.fullName}');
				setState(() {
					_isLoading = false;
				});
				widget.loginCallback(userData);
			} catch (e) {
				print('Error: $e');
				if (e is String) {
					setState(() {
						_isLoading = false;
						showErrorDialog('Une erreur est survenue', e);
					});
				} else {
					if (e.message == null) showErrorDialog('Une erreur est survenue', 'Quelque chose s\'est mal passé durant la connexion...');
					setState(() {
						_isLoading = false;
						if (e.message.contains('Unexpected character')) {
							showErrorDialog('Une erreur est survenue', 'Le serveur de Pronote Notifications est actuellement injoignable. Merci de patienter puis réessayez !');
						} else {
							showErrorDialog('Une erreur est survenue', e.message);
						}
					});
				}
			}
		} else {
			setState(() {
				_isLoading = false;
			});
		}
	}

	@override
	void initState() {
		_errorMessage = "";
		_isLoading = false;
		super.initState();
	}

	void resetForm() {
		_formKey.currentState.reset();
		_errorMessage = "";
	}

	@override
	Widget build(BuildContext context) {
		return _isLoading ?
			Scaffold(
				body: Container(
					alignment: Alignment.center,
					child: CircularProgressIndicator(),
				),
			)
		: new Scaffold(
			appBar: new AppBar(
				title: new Text('Pronote Notifications'),
			),
			body: Stack(
				children: <Widget>[
					_showForm()
				],
			));
  }

	void _showDialog() {
		// flutter defined function
		showDialog(
			context: context,
			builder: (BuildContext context) {
				// return object of type Dialog
				return CupertinoAlertDialog(
					title: new Text("Une erreur est survenue"),
					content: new Text(_errorMessage),
					actions: <Widget>[
						// usually buttons at the bottom of the dialog
						new FlatButton(
							child: new Text("Fermer"),
							onPressed: () {
							},
						),
					],
				);
			},
		);
	}


  void showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content:
              new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
			key: _formKey,
			child: new ListView(
				shrinkWrap: true,
				children: <Widget>[
					showLogo(),
					showDescription(),
					showUsernameInput(),
					showPasswordInput(),
					showPronoteURL(),
					showLoginButton(),
				],
			),
		));
  }

	Widget showLogo() {
		return new Hero(
			tag: 'pronote-logo',
			child: Padding(
				padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
				child: CircleAvatar(
				backgroundColor: Colors.transparent,
				radius: 48.0,
				child: Image.asset('assets/pronote-icon.png'),
				),
			),
		);
	}

	Widget showDescription() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
			child: new DefaultTextStyle(
				style: TextStyle(fontSize: 36, color: Colors.blue),
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Text(
									'Merci de renseigner vos identifiants Pronote. L\'URL Pronote est l\'adresse dans votre navigateur lorsque vous êtes sur pronote (pas sur l\'ENT).',
									style: TextStyle(fontSize: 15, color: Colors.green),
									textAlign: TextAlign.center
							),
						],
					),
				),
			),
		);
	}

	Widget showUsernameInput() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
			child: new TextFormField(
				maxLines: 1,
				keyboardType: TextInputType.name,
				autofocus: false,
				initialValue: _username ?? null,
				decoration: new InputDecoration(
					hintText: 'Nom d\'utilisateur',
					icon: new Icon(
						Icons.account_circle,
						color: Colors.grey,
					)
				),
				validator: (value) => value.isEmpty ? 'Le nom d\'utilisateur ne peut pas être vide' : null,
				onSaved: (value) => _username = value.trim(),
			),
		);
	}

	Widget showPasswordInput() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
			child: new TextFormField(
				maxLines: 1,
				obscureText: true,
				autofocus: false,
				initialValue: _password ?? null,
				decoration: new InputDecoration(
					hintText: 'Mot de passe',
					icon: new Icon(
					Icons.lock,
					color: Colors.grey,
					)),
				validator: (value) => value.isEmpty ? 'Le mot de passe ne peut pas être vide' : null,
				onSaved: (value) => _password = value.trim(),
			),
		);
	}

	Widget showPronoteURL() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
			child: new TextFormField(
				maxLines: 1,
				keyboardType: TextInputType.url,
				autofocus: false,
				initialValue: _pronoteURL ?? null,
				decoration: new InputDecoration(
					hintText: 'URL Pronote',
					icon: new Icon(
						Icons.http,
						color: Colors.grey,
					)
				),
				validator: (value) {
					String message = null;
					RegExp url = RegExp(r'(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w-]*)*\/?\??([^#\n\r]*)?#?([^\n\r]*)');
					if(!url.hasMatch(value)) message = 'Veuillez préciser une URL valide';
					if(value.isEmpty) message = 'L\'URL Pronote ne peut pas être vide';
					return message;
				},
				onSaved: (value) => _pronoteURL = value.trim(),
			),
		);
	}

	Widget showLoginButton() {
		return new Padding(
			padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
			child: SizedBox(
				height: 40.0,
				child: new RaisedButton(
					elevation: 5.0,
					shape: new RoundedRectangleBorder(
						borderRadius: new BorderRadius.circular(30.0)
					),
					color: Color(0xff29826c),
					child: new Text('Connexion',
					style: new TextStyle(fontSize: 20.0, color: Colors.white)),
					onPressed: validateAndSubmit,
				),
			)
		);
	}
}