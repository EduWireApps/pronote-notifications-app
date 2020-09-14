import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';

class LoginPage extends StatefulWidget {
	LoginPage({this.auth, this.loginCallback});

	final BaseAuth auth;
	final VoidCallback loginCallback;

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
			String userId = "";
			try {
				userId = await widget.auth.signIn(_username, _password, _pronoteURL);
				print('Signed in: $userId');
				setState(() {
					_isLoading = false;
				});

				if (userId.length > 0 && userId != null) {
					widget.loginCallback();
				}
			} catch (e) {
				print('Error: $e');
				setState(() {
					_isLoading = false;
					_errorMessage = e;
					_showDialog();
				});
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
		return new Scaffold(
			appBar: new AppBar(
				title: new Text('Pronote Notifications'),
			),
			body: Stack(
				children: <Widget>[
					_showForm(),
					_showCircularProgress(),
				],
			));
  }

	Widget _showCircularProgress() {
		if (_isLoading) {
			return Center(child: CircularProgressIndicator());
		}
		return Container(
			height: 0.0,
			width: 0.0,
		);
	}

	void _showDialog() {
		// flutter defined function
		showDialog(
			context: context,
			builder: (BuildContext context) {
				// return object of type Dialog
				return AlertDialog(
					title: new Text("Une erreur est survenue"),
					content: new Text(_errorMessage),
					actions: <Widget>[
						// usually buttons at the bottom of the dialog
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


//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content:
//              new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
			key: _formKey,
			child: new ListView(
				shrinkWrap: true,
				children: <Widget>[
					showLogo(),
					showInformation(),
					showEmailInput(),
					showPasswordInput(),
					showPronoteURL(),
					showPrimaryButton(),
				],
			),
		));
  }

	Widget showLogo() {
		return new Hero(
			tag: 'hero',
			child: Padding(
				padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
				child: CircleAvatar(
				backgroundColor: Colors.transparent,
				radius: 48.0,
				child: Image.asset('assets/flutter-icon.png'),
				),
			),
		);
	}

	Widget showEmailInput() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
			child: new TextFormField(
				maxLines: 1,
				keyboardType: TextInputType.emailAddress,
				autofocus: false,
				decoration: new InputDecoration(
					hintText: 'Nom d\'utilisateur',
					icon: new Icon(
					Icons.account_circle,
					color: Colors.grey,
					)),
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

	Widget showInformation() {
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

	Widget showPronoteURL() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
			child: new TextFormField(
				maxLines: 1,
				autofocus: false,
				decoration: new InputDecoration(
						hintText: 'URL Pronote',
						icon: new Icon(
							Icons.http,
							color: Colors.grey,
						)),
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

	Widget showPrimaryButton() {
		return new Padding(
			padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
			child: SizedBox(
			height: 40.0,
			child: new RaisedButton(
				elevation: 5.0,
				shape: new RoundedRectangleBorder(
					borderRadius: new BorderRadius.circular(30.0)),
				color: Color(0xff29826c),
				child: new Text('Connexion',
					style: new TextStyle(fontSize: 20.0, color: Colors.white)),
				onPressed: validateAndSubmit,
			),
		));
  	}
}