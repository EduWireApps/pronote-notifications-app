import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, { String title, String content }) {
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