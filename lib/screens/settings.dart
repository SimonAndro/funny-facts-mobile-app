import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:funny_facts/providers/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:funny_facts/services/notification.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<bool> isNotificationOn;

  @override
  void initState() {

    isNotificationOn = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('isNotificationOn') ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text("Turn on Notifications", style: TextStyle(fontSize: 16)),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Receive one funny fact everyday",
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ]),
              const Expanded(child: SizedBox()),
              FutureBuilder<bool>(
                  future: isNotificationOn,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasError) {
                      debugPrint(
                          'toggle notification snapshot Error: ${snapshot.error}');
                    }
                    return Switch(
                      value: snapshot.data ?? false,
                      onChanged: (value) {
                        _toggleNotifications();
                      },
                      activeTrackColor: Colors.lightBlueAccent,
                      activeColor: Colors.blue,
                    );
                  })
            ],
          )
        ],
      ),
    );
  }

  Future<void> _toggleNotifications() async {
    final SharedPreferences prefs = await _prefs;
    final bool toggleNotification =
        (prefs.getBool('isNotificationOn') ?? false) == false;

    setState(() {
      isNotificationOn = prefs
          .setBool('isNotificationOn', toggleNotification)
          .then((bool success) {

          //turn on or off notifications
          NotificationProvider notificationProvider = NotificationProvider();
          if(toggleNotification){//turn on
            NotificationClass().cancelAllNotifications();
            notificationProvider.setComeBackNotification();
            notificationProvider.setNextDayNotification();

          }else{ // turn off
            NotificationClass().cancelAllNotifications();
            notificationProvider.setComeBackNotification();
          }

        return toggleNotification;
      });
    });
  }
}
