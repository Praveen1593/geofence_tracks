import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  // Future<void> showNotification(String title, String body) async {
  //   const AndroidNotificationDetails androidDetails =
  //   AndroidNotificationDetails('geofence_channel', 'Geofence Alerts',
  //       importance: Importance.high, priority: Priority.high);
  //
  //   const NotificationDetails platformDetails =
  //   NotificationDetails(android: androidDetails);
  //
  //   await _flutterLocalNotificationsPlugin.show(
  //       0, title, body, platformDetails);
  // }

  Future<void> showNotification(String status, String geofenceName) async {
    var androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Geofence Alert',
      'You have $status: $geofenceName',
      notificationDetails,

    );
    if (kDebugMode) {
      print('You have $status: ${geofenceName}');
    }
  }


}
