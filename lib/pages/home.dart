import 'package:flutter/material.dart';
import 'package:pronote_notifications/services/authentication.dart';

class HomePage extends StatefulWidget {
	HomePage({Key key, this.auth, this.userId, this.logoutCallback})
		: super(key: key);

	final BaseAuth auth;
	final VoidCallback logoutCallback;
	final String userId;

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

//  void _checkEmailVerification() async {
//    _isEmailVerified = await widget.auth.isEmailVerified();
//    if (!_isEmailVerified) {
//      _showVerifyEmailDialog();
//    }
//  }

//  void _resentVerifyEmail(){
//    widget.auth.sendEmailVerification();
//    _showVerifyEmailSentDialog();
//  }

//  void _showVerifyEmailDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content: new Text("Please verify account in the link sent to email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Resent link"),
//              onPressed: () {
//                Navigator.of(context).pop();
//                _resentVerifyEmail();
//              },
//            ),
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content: new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

	signOut() async {
		try {
		await widget.auth.signOut();
		widget.logoutCallback();
		} catch (e) {
		print(e);
		}
	}

  Widget showTodoList() {
      return Center(
        child: Text(
            "Welcome. Your list is empty",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
          ],
        ),
        body: showTodoList()
	);
  }
}