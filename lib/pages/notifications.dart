import 'package:flutter/material.dart';
import 'package:pronote_notifications/api.dart';
import 'package:pronote_notifications/widgets/dialogs.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage();

  @override
  State<StatefulWidget> createState() {
    return _NotificationsPageState();
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    refreshNotifications();
  }

  void refreshNotifications() async {
    API.getUserNotifications().then((result) {
      setState(() {
        _fetched = true;
        _notifications = result;
      });
    });
  }

  Widget _buildList() {
    return _fetched
        ? (_notifications.length != 0
            ? RefreshIndicator(
                child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                                leading: Container(
                                    child:
                                        _notifications[index].type == 'homework'
                                            ? Icon(Icons.today)
                                            : Icon(Icons.assessment)),
                                title: Text(_notifications[index].title,
                                    style: new TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    _notifications[index].type == 'homework'
                                        ? (_notifications[index].hasSmallBody
                                            ? _notifications[index].smallBody
                                            : _notifications[index].body)
                                        : _notifications[index].body),
                                onTap: () {
                                  showInfoDialog(context,
                                      title: _notifications[index].title,
                                      content: _notifications[index].body);
                                })
                          ],
                        ),
                      );
                    }),
                onRefresh: _getData,
              )
            : RefreshIndicator(
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                  child: Image(
                                      image: AssetImage('bell.png'),
                                      height: 100,
                                      width: 100)),
                              SizedBox(height: 30),
                              Center(
                                  child: Text(
                                      'Aucune notification pour le moment !',
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center))
                            ]),
                        height: MediaQuery.of(context).size.height - 100)),
                onRefresh: _getData,
              ))
        : Center(child: CircularProgressIndicator());
  }

  Future<void> _getData() async {
    setState(() {
      refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Container(child: _buildList()),
    );
  }
}
