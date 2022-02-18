import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funny_facts/models/fact.dart';
import 'package:funny_facts/providers/notification.dart';
import 'package:funny_facts/screens/home.dart';
import 'package:funny_facts/screens/saved.dart';
import 'package:funny_facts/screens/settings.dart';
import 'package:funny_facts/services/api.dart';
import 'package:funny_facts/services/database.dart';
import 'package:funny_facts/services/notification.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Funny Facts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Funny Facts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final DatabaseClass databaseClass = DatabaseClass();

  NotificationProvider notificationProvider = NotificationProvider();

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    const SavedScreen(),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {

    if(index == 1)
    {
      _widgetOptions.removeAt(1);
      _widgetOptions.insert(1, SavedScreen(key: GlobalKey()));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {

    // initialize notifications
    NotificationClass().init(onSelect: onNotificationSelect);
    notificationProvider.setNextDayNotification();
    notificationProvider.setNextDayNotification();

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: IndexedStack(
          alignment: AlignmentDirectional.center,
          index: _selectedIndex,
          children: _widgetOptions,
        )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black45,
        selectedItemColor: Colors.blue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.web_stories),
            label: 'New',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void onNotificationSelect(Fact fact) {
    _showMyDialog(fact);
  }

  Future<void> _showMyDialog(Fact fact) async {

    notificationProvider.initNextNotification();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('A funny fact everyday'),
          content: SingleChildScrollView(
            child: Text(fact.text),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save,color:Colors.green),
                  Text("Save"),
                ],
              ),
              onPressed: () {
                databaseClass.save(fact);

                Fluttertoast.showToast(
                    msg: "Saved Successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black45,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.share,color:Colors.green),
                  Text("Share"),
                ],
              ),
              onPressed: () async {
                final box = context.findRenderObject() as RenderBox?;
                await Share.share(
                    fact.text + "\n ---------------\n via Funny Facts App",
                    subject: "Funny Fact from the Funny Fact App",
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
