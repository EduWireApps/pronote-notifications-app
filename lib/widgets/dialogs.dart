import 'package:flutter/material.dart';

void showInfoDialog(BuildContext context, { String title, String content }) {
	showDialog(
		context: context,
		builder: (BuildContext context) {
			return AlertDialog(
				title: new Text(title),
				content:
        new Text(content),
        actions: <Widget>[
          new ElevatedButton(
            child: new Text("Fermer"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ]
      );
		},
	);
}
