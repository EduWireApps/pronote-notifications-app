import 'package:url_launcher/url_launcher.dart';

void launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
