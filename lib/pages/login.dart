import 'package:flutter/material.dart';
import 'package:pronote_notifications/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pronote_notifications/widgets/dialogs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pronote_notifications/url.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.api, this.loginCallback});

  final BaseAPI api;
  final Function loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  // used to store credentials before sending them to the server
  String _username;
  String _password;
  String _pronoteURL;

  String _pronoteURLInfoText = 'Sélectionnez votre établissement';

  String _geolocationErrorMessage;
  bool _useGeolocation = true;
  String _selectedEstablishment;
  bool _establishmentsLoaded = false;
  List<dynamic> _establishments;

  bool _isLoading;
  final _pronoteGeoController = TextEditingController();
  final _pronoteURLController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
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
          _pronoteURLController.text = pronoteURL;
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
        final userData =
            await widget.api.register(_username, _password, _pronoteURL);
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
            showInfoDialog(context,
                title: 'Une erreur est survenue', content: e);
          });
        } else {
          if (e.message == null)
            showInfoDialog(context,
                title: 'Une erreur est survenue',
                content:
                    'Quelque chose s\'est mal passé durant la connexion...');
          setState(() {
            _isLoading = false;
            if (e.message.contains('Unexpected character')) {
              showInfoDialog(context,
                  title: 'Une erreur est survenue',
                  content:
                      'Le serveur de Notifications pour Pronote est actuellement injoignable. Merci de patienter puis réessayez !');
            } else {
              showInfoDialog(context,
                  title: 'Une erreur est survenue', content: e.message);
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
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'Problèmes de connexion') {
                  showInfoDialog(context,
                      title: "Aide à la connexion",
                      content:
                          "Si vous ne parvenez pas à vous connecter, n'hésitez surtout pas à nous envoyer un mail à androz2091@gmail.com. Nous répondons en quelques heures.",
                      actions: [
                        new ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueAccent)),
                            child: new Text("Envoyer un mail"),
                            onPressed: () {
                              launchURL("mailto:androz2091@gmail.com?subject=Problème de connexion à Notifications pour Pronote&body=Bonjour, je rencontre des difficultés pour me connecter à l'application.\n\nMéthode d'authentification:\n" +
                                  (_useGeolocation
                                      ? 'Géolocalisation (' +
                                          (_establishmentsLoaded
                                              ? _establishments.length
                                                      .toString() +
                                                  ' établissements chargés)'
                                              : 'aucun établissement chargé)')
                                      : 'URL personnalisée (' +
                                          (_pronoteURL ?? 'aucune URL') +
                                          ')') +
                                  "\n\nSerait-il possible de m'aider ?\n\nCordialement,\nYour Name Here");
                            })
                      ]);
                } else {
                  showAboutAppDialog(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return ['Problèmes de connexion', 'À propos']
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[_showForm()],
        ));
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
              if (_useGeolocation) showPronoteEstablishmentsDropdown(),
              if (!_useGeolocation) showPronoteURL(),
              showSwitchMethod(),
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
                  textAlign: TextAlign.center),
              if (_geolocationErrorMessage != null)
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(_geolocationErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14)))
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
            )),
        validator: (value) => value.isEmpty
            ? 'Le nom d\'utilisateur ne peut pas être vide'
            : null,
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
        validator: (value) =>
            value.isEmpty ? 'Le mot de passe ne peut pas être vide' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  Widget showSwitchMethod() {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            _useGeolocation = !_useGeolocation;
            if (!_useGeolocation) {
              _pronoteGeoController.text = null;
            }
          });
        },
        child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
                _useGeolocation
                    ? 'ou entrez une URL personnalisée'
                    : 'ou chercher établissements à proximité',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline))));
  }

  Widget showPronoteURL() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          readOnly: _isLoading,
          maxLines: 1,
          keyboardType: TextInputType.url,
          autofocus: false,
          controller: _pronoteURLController,
          decoration: new InputDecoration(
              hintText: 'URL Pronote',
              icon: new Icon(
                Icons.http,
                color: Colors.grey,
              )),
          validator: (value) {
            String message;
            if (value.isEmpty) message = 'L\'URL Pronote ne peut pas être vide';
            return message;
          },
          onSaved: (value) => _pronoteURL = value.trim(),
        ));
  }

  Widget showPronoteEstablishmentsDropdown() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: _establishmentsLoaded
            ? Row(children: [
                Container(
                  child: new Icon(
                    Icons.school,
                    color: Colors.grey,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: DropdownButton<String>(
                      value: _selectedEstablishment ?? _establishments[0].name,
                      onChanged: !_isLoading
                          ? (String newValue) {
                              setState(() {
                                _selectedEstablishment = newValue;
                                _pronoteURL = _establishments
                                    .firstWhere((es) => es.name == newValue)
                                    .url;
                              });
                            }
                          : null,
                      items: (_establishments
                              .map((e) => e.name.toString())
                              .toList())
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ))
              ])
            : new TextFormField(
                readOnly: true,
                maxLines: 1,
                autofocus: false,
                controller: _pronoteGeoController,
                decoration: new InputDecoration(
                    hintText: _pronoteURLInfoText,
                    icon: new Icon(
                      Icons.school,
                      color: Colors.grey,
                    )),
                validator: (value) => 'Veuillez sélectionner un établissement',
                onTap: () {
                  setState(() {
                    _geolocationErrorMessage = null;
                    _pronoteURLInfoText = 'Chargement des étab. à proximité...';
                  });
                  _determinePosition().then((value) async {
                    final establishments = await widget.api
                        .getEstablishments(value.latitude, value.longitude);
                    setState(() {
                      _establishments = establishments;
                      _establishmentsLoaded = true;
                    });
                  }, onError: (e) {
                    print(e);
                    setState(() {
                      _pronoteURLInfoText =
                          'Accès à la géolocalisation impossible !';
                      _geolocationErrorMessage =
                          'La géolocalisation est nécessaire pour déterminer les établissements prêts de chez vous ! Vous pouvez aussi entrer l\'URL Pronote manuellement.';
                    });
                  });
                },
              ));
  }

  Widget showLoginButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 30.0),
        child: SizedBox(
          height: 40.0,
          child: new ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Color(0xff29826c),
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
            child: _isLoading
                ? new LinearProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(41, 170, 108, 1)))
                : new Text(
                    'Connexion',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
            onPressed: _isLoading ? () => {} : validateAndSubmit,
          ),
        ));
  }
}
