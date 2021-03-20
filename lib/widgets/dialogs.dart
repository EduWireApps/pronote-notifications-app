import 'package:flutter/material.dart';
import 'package:pronote_notifications/url.dart';

void showInfoDialog(BuildContext context, {String title, String content, List<Widget> actions}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            ...(actions ?? []),
            new ElevatedButton(
              child: new Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    },
  );
}

void showAboutAppDialog (BuildContext context) {
  showInfoDialog(context, title: 'À propos',content: 'Notifications pour Pronote est une application gratuite, open source et sans publicité développée par des étudiants !', actions: [
      new ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent)),
        child: new Text("Faire un don"),
        onPressed: () {
          launchURL('https://paypal.me/andr0z');
        },
      )
  ]);
}
