import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:funny_facts/services/notification.dart';

class SettingSCreen extends StatefulWidget {
  @override
  _SettingSCreenState createState() => _SettingSCreenState();
}

class _SettingSCreenState extends State<SettingSCreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<bool> isNotificationOn;

  @override
  void initState() {
    super.initState();
    isNotificationOn = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('isNotificationOn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Turn on Notifications", style: TextStyle(fontSize: 16)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Receive one funny fact everyday",
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ]),
              Expanded(child: SizedBox()),
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

        //!todo turn on or off notifications

        return toggleNotification;
      });
    });
  }
}
