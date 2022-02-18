import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:funny_facts/models/fact.dart';
import 'package:funny_facts/services/api.dart';
import 'package:funny_facts/services/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final ApiService api = ApiService();

  void setComeBackNotification() {
    //schedule notification to bring back user if they
    //take long to comeback
    String bringBackMessage = "Checkout some new funny facts now";
    NotificationClass().cancelNotification(bringBackMessage.hashCode);
    NotificationClass().scheduleRepeatNotification(bringBackMessage,
        NotificationClass.comeBackPayLoad, RepeatInterval.everyMinute);
  }

  void setNextDayNotification() {
    //schedule notification for next day if none
    // and user has turned on notifications
    _prefs.then((SharedPreferences prefs) async {
      String nextDateString =
          prefs.getString(NotificationClass.nextNotificationDate) ??
              DateTime.now().toIso8601String(); //get next notification time

      DateTime nextDate = DateTime.parse(nextDateString);

      if (DateTime.now().add(const Duration(minutes: 1)).isAfter(nextDate)) {
        await initNextNotification();
      }
    });
  }

  Future<void> initNextNotification() async {
    _prefs.then((SharedPreferences prefs) async {
      try {
        Fact fact = await api.getFact();
        NotificationClass()
            .scheduleNextNotification(fact, const Duration(days: 1));

        String timeStamp =
            DateTime.now().add(const Duration(days: 1)).toIso8601String();
        prefs.setString(NotificationClass.nextNotificationDate, timeStamp);
      } catch (e) {
        debugPrint("enable to create next notification");
        debugPrint(e.toString());
      }
    });
  }
}
