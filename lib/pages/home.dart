import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';

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

	@override
	void initState() {
		super.initState();

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
					body: Center(
						child: ListView(
							shrinkWrap: true,
							padding: EdgeInsets.symmetric(horizontal: 20),
							children: <Widget>[
								avatar,
								description,
								buttonLogout
							],
						),
					),
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