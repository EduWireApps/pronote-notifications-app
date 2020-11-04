import 'package:flutter/material.dart';
import 'package:pronote_notifications/api.dart';
import 'package:pronote_notifications/pages/root.dart';

void main() {
	runApp(new MyApp());
}

Map<int, Color> color =
{
	50:Color.fromRGBO(41, 130, 108, .1),
	100:Color.fromRGBO(41, 130, 108, .2),
	200:Color.fromRGBO(41, 130, 108, .3),
	300:Color.fromRGBO(41, 130, 108, .4),
	400:Color.fromRGBO(41, 130, 108, .5),
	500:Color.fromRGBO(41, 130, 108, .6),
	600:Color.fromRGBO(41, 130, 108, .7),
	700:Color.fromRGBO(41, 130, 108, .8),
	800:Color.fromRGBO(41, 130, 108, .9),
	900:Color.fromRGBO(41, 130, 108, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF29826c, color);

class MyApp extends StatefulWidget {

	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			title: 'Notifications pour Pronote ',
			debugShowCheckedModeBanner: false,
			theme: new ThemeData(
				primarySwatch: colorCustom,
			),
			home: new RootPage(api: new API())
		);
	}
}
