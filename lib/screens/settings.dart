import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingSCreen extends StatefulWidget {
  @override
  _SettingSCreenState createState() => _SettingSCreenState();
}

class _SettingSCreenState extends State<SettingSCreen> {
  bool isNotificationOn = false;

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
              Switch(
                value: isNotificationOn,
                onChanged: (value) {
                  setState(() {
                    isNotificationOn = value;
                    print(isNotificationOn);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ],
          )
        ],
      ),
    );
  }
}
