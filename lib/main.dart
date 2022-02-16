import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:useless_quotes/screens/home.dart';
import 'package:useless_quotes/screens/saved.dart';
import 'package:useless_quotes/screens/settings.dart';
import 'package:useless_quotes/services/api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
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

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SavedScreen(),
    SettingSCreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          )
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
