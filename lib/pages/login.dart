import 'package:flutter/material.dart';
import 'package:pronote_notifications/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pronote_notifications/widgets/dialogs.dart';
import 'package:geolocator/geolocator.dart';

class LoginPage extends StatefulWidget {
	LoginPage({this.api, this.loginCallback});

	final BaseAPI api;
	final Function loginCallback;

	@override
	State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	final _formKey = new GlobalKey<FormState>();

	String _username;
	String _password;
	String _pronoteURL;

  String _pronoteURLInfoText = 'Sélectionnez votre établissement';

  bool _establishmentsLoaded = false;
  List<dynamic> _establishments;

	bool _isLoading;
	final _usernameController = TextEditingController();

	@override
	void initState () {
		super.initState();

		setState(() {
      _isLoading = false;
		});

		SharedPreferences.getInstance().then((instance) {
				final username = instance.getString('form_pronote_username');
				final pronoteURL = instance.getString('form_pronote_url');
				if (username != null && pronoteURL != null) {
					setState(() {
						_usernameController.text = username;
					});
				}
		});
	}

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
			_isLoading = true;
		});
		if (validateAndSave()) {
			try {
				final userData = await widget.api.register(_username, _password, _pronoteURL);
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
						showInfoDialog(context, title: 'Une erreur est survenue', content: e);
					});
				} else {
					if (e.message == null) showInfoDialog(context, title: 'Une erreur est survenue', content: 'Quelque chose s\'est mal passé durant la connexion...');
					setState(() {
						_isLoading = false;
						if (e.message.contains('Unexpected character')) {
							showInfoDialog(context, title: 'Une erreur est survenue', content: 'Le serveur de Notifications pour Pronote est actuellement injoignable. Merci de patienter puis réessayez !');
						} else {
							showInfoDialog(context, title: 'Une erreur est survenue', content: e.message);
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

	void resetForm() {
		_formKey.currentState.reset();
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
				title: new Text('Notifications pour Pronote'),
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
				return AlertDialog(
					title: new Text("Comment récupérer l'URL Pronote ?"),
					content: Wrap(
						children: [
							new Text('Cette URL est présente en haut de votre navigateur lorsque vous êtes connecté sur Pronote. Cette URL doit ressembler à https://0310047h.index-education.net/pronote/. Attention, ce n\'est pas l\'URL de l\'ENT mais bien celle de Pronote !\n'),
							new Image(image: AssetImage('url-pronote.png'))
						],
					),
					actions: <Widget>[
						// usually buttons at the bottom of the dialog
						new TextButton(
							child: new Text("J'ai compris !"),
							onPressed: () {
								Navigator.pop(context, true);
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
				child: Image.asset('assets/launcher-icon.png'),
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
									'Bienvenue, merci de renseigner vos identifiants pour commencer à recevoir les notifications ! 🔔',
									style: TextStyle(fontSize: 15, color: Colors.black),
									textAlign: TextAlign.center
							),
							new GestureDetector(
									onTap: () {
											_showDialog();
									},
									child: const Text('Qu\'est-ce que "URL Pronote" ?',
										style: TextStyle(fontSize: 15, color: Colors.black, decoration: TextDecoration.underline),
										textAlign: TextAlign.center
									)
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
				readOnly: _isLoading,
				maxLines: 1,
				keyboardType: TextInputType.name,
				autofocus: false,
				controller: _usernameController,
				initialValue: null,
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
				readOnly: _isLoading,
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

  Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the 
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately. 
          return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
        } 

        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale 
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error(
              'Location permissions are denied');
        }
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
  }

	Widget showPronoteURL() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
			child: _establishmentsLoaded ? Row(
        children: [
          Container(
            child: new Icon(
              Icons.school,
              color: Colors.grey,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: DropdownButton<String>(
            value: _establishments[0].name,
            onChanged: (String newValue) {
              setState(() {
                _pronoteURL = _establishments.firstWhere((es) => es.name == newValue).url;
              });
            },
            items: (_establishments.map((e) => e.name.toString()).toList()).map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ))
      ]) :
      new TextFormField(
        readOnly: true,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        initialValue: _password ?? null,
        decoration: new InputDecoration(
          hintText: _pronoteURLInfoText,
          icon: new Icon(
          Icons.school,
          color: Colors.grey,
        )),
        validator: (value) => value.isEmpty ? 'Le mot de passe ne peut pas être vide' : null,
        onSaved: (value) => _password = value.trim(),
        onTap: () {
          _determinePosition().then((value) async {
            setState(() {
              _pronoteURLInfoText = 'Chargement des étab. à proximité...';            
            });
            print('Getting establishments...');
            final establishments = await widget.api.getEstablishments(value.latitude, value.longitude);
            print('Got establishments');
            setState(() {
              _establishments = establishments;
              _establishmentsLoaded = true;
            });
          }, onError: (e) {
            print(e);
            if (e == 'Location services are disabled.') {
              _pronoteURLInfoText = 'Veuillez activer la géolocalisation !';
            } else if (e == 'Location permissions are permanently denied, we cannot request permissions.') {
              _pronoteURLInfoText = 'Impossible d\'accéder à la géolocalisation';
            } else if (e == 'Location permissions are denied') {
              _pronoteURLInfoText = 'Autorisez la géolocalisation (ou rentrez une URL manuellement)';
            } else {
              _pronoteURLInfoText = 'Une erreur s\'est produite.';
            }
          });
        },
      )
		);
	}

	Widget showLoginButton() {
		return new Padding(
			padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
			child: SizedBox(
				height: 40.0,
				child: new ElevatedButton(
					style: ElevatedButton.styleFrom(
						primary: Color(0xff29826c),
						elevation: 5.0,
						shape: new RoundedRectangleBorder(
							borderRadius: new BorderRadius.circular(30.0)
						)
					),
					child: _isLoading ? new LinearProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(41, 170, 108, 1))) : new Text('Connexion',
						style: new TextStyle(fontSize: 20.0, color: Colors.white),
					),
					onPressed: _isLoading ? () => {} : validateAndSubmit,
				),
			)
		);
	}
}