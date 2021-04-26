import 'package:url_launcher/url_launcher.dart';

Future<bool> launchURL(_url) async {
  final canLaunchURL = await canLaunch(_url);
  if (canLaunchURL) launch(_url);
  return canLaunchURL;
}
