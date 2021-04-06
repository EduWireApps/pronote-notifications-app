import 'package:flutter/material.dart';
import 'package:pronote_notifications/api.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:pronote_notifications/pages/notifications.dart';
import 'package:pronote_notifications/widgets/dialogs.dart';
import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.userData, this.logoutCallback}) : super(key: key);

  final VoidCallback logoutCallback;
  final UserData userData;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool notificationsHomeworks;
  bool notificationsMarks;

  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    notificationsHomeworks = widget.userData.notificationsHomeworks;
    notificationsMarks = widget.userData.notificationsMarks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Notifications pour Pronote'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String value) async {
                if (value == 'À propos') {
                  showAboutAppDialog(context);
                } else {
                  inAppReview.openStoreListing();
                }
              },
              itemBuilder: (BuildContext context) {
                return ['Laisser un avis', 'À propos'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: SettingsList(
          contentPadding: EdgeInsets.only(top: 20),
          sections: [
            SettingsSection(
              title: 'Vos informations',
              tiles: [
                SettingsTile(
                    title: widget.userData.fullName,
                    leading: Icon(Icons.account_circle)),
                SettingsTile(
                    title:
                        "${widget.userData.establishment} (${widget.userData.studentClass})",
                    leading: Icon(Icons.school)),
              ],
            ),
            SettingsSection(
              title: 'Gestion des notifications',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Nouveaux devoirs',
                  leading: Icon(Icons.today),
                  switchValue: notificationsHomeworks,
                  onToggle: (bool value) async {
                    setState(() {
                      notificationsHomeworks = value;
                    });
                    await API.updateSettings(
                        notificationsHomeworks, notificationsMarks);
                  },
                ),
                SettingsTile.switchTile(
                    title: 'Nouvelles notes',
                    leading: Icon(Icons.assessment),
                    switchValue: notificationsMarks,
                    onToggle: (bool value) async {
                      setState(() {
                        notificationsMarks = value;
                      });
                      await API.updateSettings(
                          notificationsHomeworks, notificationsMarks);
                    },
                    enabled: true),
                SettingsTile(
                  title: 'Historique des notifications',
                  leading: Icon(Icons.history),
                  enabled: true,
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Compte',
              tiles: [
                SettingsTile(
                  title: 'Déconnexion',
                  leading: _loggingOut
                      ? Container(
                          height: 15,
                          width: 15,
                          margin: EdgeInsets.all(5),
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : Icon(Icons.exit_to_app),
                  onPressed: (context) {
                    setState(() {
                      _loggingOut = true;
                    });
                    logout();
                  },
                )
              ],
            )
          ],
        ));
  }

  logout() async {
    try {
      await API.logout();
      widget.logoutCallback();
      _loggingOut = false;
    } catch (e) {
      print(e);
    }
  }
}
