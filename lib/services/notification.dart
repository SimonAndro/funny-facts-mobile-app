import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:useless_quotes/models/fact.dart';

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

  Future<void> init() async {
    final AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    tz.initializeTimeZones();
  }

  Future selectNotification(String? payload) async {
    Fact fact = getFactFromPayload(payload ?? '');
    cancelNotification(fact);
    scheduleNotificationNextDay(fact, notificationTitle);
  }

  void showNotification(Fact fact, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        fact.hashCode,
        applicationName,
        notificationMessage,
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                channelDescription: channelDescription)),
        payload: jsonEncode(fact));
  }

  void scheduleNotificationNextDay(
      Fact fact, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        fact.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(new Duration(days: 365)),
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                channelDescription: channelDescription)),
        payload: jsonEncode(fact),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelNotification(Fact fact) async {
    await flutterLocalNotificationsPlugin.cancel(fact.hashCode);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Fact getFactFromPayload(String payload) {
    Map<String, dynamic> json = jsonDecode(payload);
    Fact fact = Fact.fromJson(json);
    return fact;
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }
}
