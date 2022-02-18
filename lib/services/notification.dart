import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:funny_facts/models/fact.dart';

class NotificationClass {
  static final NotificationClass _notificationService =
      NotificationClass._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationClass() {
    return _notificationService;
  }

  NotificationClass._internal();

  static const applicationName = "Funny Facts";

  static const channelDescription = "To bring you a funny fact daily";

  static const notificationTitle = "Your daily funny fact is here!";

  static const channel_id = "123";

  static const comeBackPayLoad = "comeBack";

  static const nextNotificationDate = "nextNotificationDate";

  late Function? onSelect;

  Future<void> init({Function? onSelect}) async {

    this.onSelect = onSelect;

    final AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    tz.initializeTimeZones();
  }

  Future selectNotification(String? payload) async {

    debugPrint("selected notification payload $payload");

    if(payload != comeBackPayLoad)
    {
       Fact fact = getFactFromPayload(payload ?? '');
       cancelNotification(fact.hashCode);

       onSelect!(fact);
    }

  }

  void showNotification(Fact fact, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        fact.hashCode,
        applicationName,
        fact.text,
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                channelDescription: channelDescription)),
        payload: fact.toJson());
  }

  void scheduleNextNotification(
      Fact fact, Duration duration) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        fact.hashCode,
        applicationName,
        fact.text,
        tz.TZDateTime.now(tz.local).add(duration),
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                channelDescription: channelDescription)),
        payload: fact.toJson(),
        androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  void scheduleRepeatNotification(
      String message, String payload, RepeatInterval interval) async {

    await flutterLocalNotificationsPlugin.periodicallyShow(
        message.hashCode,
        applicationName,
        message,
        interval,
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                channelDescription: channelDescription)),
        payload: payload,
        androidAllowWhileIdle: true);
  }

  void cancelNotification(int hashCode) async {
    await flutterLocalNotificationsPlugin.cancel(hashCode);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Fact getFactFromPayload(String payload) {

    Map<String, dynamic> json = jsonDecode(payload);

    Fact fact = Fact(
      identifier: json['_identifier'],
      text: json['_text'],
      id: -1,
    );

    return fact;
  }

  Future<bool> isLaunchFromNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }
}
