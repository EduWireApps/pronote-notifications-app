import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';
import 'package:settings_ui/settings_ui.dart';

class HomePage extends StatefulWidget {
	HomePage({Key key, this.auth, this.userData, this.logoutCallback})
		: super(key: key);

	final BaseAuth auth;
	final VoidCallback logoutCallback;
	final UserData userData;

	@override
	State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

	//bool _isEmailVerified = false;
	bool notificationsHomeworks;
	bool notificationsMarks;

	@override
	void initState() {
		super.initState();
		notificationsHomeworks = widget.userData.notificationsHomeworks;
		notificationsMarks = widget.userData.notificationsMarks;
		//_checkEmailVerification();
	}

	@override
	Widget build(BuildContext context) {
		final avatar = Padding(
			padding: EdgeInsets.all(20),
			child: Hero(
					tag: 'logo',
					child: SizedBox(
						height: 160,
						child: CircleAvatar(
							radius: 50,
							backgroundImage: MemoryImage(Base64Codec().decode(widget.userData.avatarBase64)),
						),
					)
			),
		);
		final description = Padding(
			padding: EdgeInsets.all(10),
			child: RichText(
				textAlign: TextAlign.justify,
				text: TextSpan(
						text: 'Anim ad ex officia nulla anim ipsum ut elit minim id non ad enim aute. Amet enim adipisicing excepteur ea fugiat excepteur enim veniam veniam do quis magna. Cupidatat quis exercitation ut ipsum dolor ipsum. Qui commodo nostrud magna consectetur. Nostrud culpa laboris Lorem aliqua non ut veniam culpa deserunt laborum occaecat officia.',
						style: TextStyle(color: Colors.black, fontSize: 20)
				),
			),
		);
		final buttonLogout = FlatButton(
				child: Text(
					'Logout', style: TextStyle(color: Colors.black87, fontSize: 16),),
				onPressed: () {
					logout();
				}
		);
		return SafeArea(
				child: Scaffold(
					appBar: new AppBar(
						title: new Text('Pronote Notifications'),
					),
					body: SettingsList(
						sections: [
							SettingsSection(
								title: 'Vos informations',
								tiles: [
									SettingsTile(
										title: widget.userData.fullName,
										leading: Icon(Icons.work),
										onTap: () {},
										enabled: false,
									),
									SettingsTile(
										title: widget.userData.studentClass,
										leading: Icon(Icons.school),
										onTap: () {},
										enabled: false,
									),
								],
							),
							SettingsSection(
								title: 'Notifications',
								tiles: [
									SettingsTile.switchTile(
										title: 'Nouveaux devoirs',
										leading: Icon(Icons.work),
										switchValue: notificationsHomeworks,
										onToggle: (bool value) async {
											setState(() {
												notificationsHomeworks = value;
											});
											await widget.auth.updateSettings(notificationsHomeworks, notificationsMarks);
										},
									),
									SettingsTile.switchTile(
										title: 'Nouvelles notes',
										leading: Icon(Icons.assignment_turned_in_sharp),
										switchValue: notificationsMarks,
										onToggle: (bool value) async {
											setState(() {
											  notificationsMarks = value;
											});
											await widget.auth.updateSettings(notificationsHomeworks, notificationsMarks);
										},
										enabled: true
									),
								],
							),
							SettingsSection(
								title: 'Compte',
								tiles: [
									SettingsTile(
										title: 'Déconnexion',
										leading: Icon(Icons.exit_to_app),
										onTap: () {
											logout();
										},
									),
								],
							),
						],
					)
				)
		);
	}

	logout() async {
		try {
			await widget.auth.logout();
			widget.logoutCallback();
		} catch (e) {
			print(e);
		}
	}

  Widget showTodoList() {
      return Center(
        child: Text(
            'Welcome. Your name is ${widget.userData.fullName}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
        )
      );
  }
}