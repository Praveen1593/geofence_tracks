import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../main.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initBackgroundLocation() async {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      String status = event.action == 'ENTER' ? 'Entered' : 'Exited';

      if (kDebugMode) {
        print("🚀 Geofence Event: You have $status ${event.identifier}");
      }

      showNotification(status, event.identifier);
      showInAppAlert(status, event.identifier);
      saveMovementHistory(event);
    });

    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10, // ✅ Reduce distance threshold for updates (default: 50m)
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      debug: true,
      geofenceProximityRadius: 500, // ✅ Increase to detect movement sooner
      geofenceModeHighAccuracy: true,
      useSignificantChangesOnly: false,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,

      // ✅ Increase location update rate
      locationUpdateInterval: 30000, // Request location updates every 30 seconds (default: 60s+)
      fastestLocationUpdateInterval: 15000, // Minimum interval between updates (15s)
      deferTime: 0, // Get updates as soon as possible
      heartbeatInterval: 60, // Heartbeat event fires every 60s even when stationary


    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
    // Listen for location updates
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (kDebugMode) {
        print("[Location Update] ${location.coords.latitude}, ${location.coords.longitude}");
      }
    });
    // Handle geofence events
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      if (kDebugMode) {
        print("[Geofence] ${event.identifier} - ${event.action}");
      }
    });
    // bg.BackgroundGeolocation.addGeofence(bg.Geofence(
    //   identifier: "My Geofence",
    //   latitude: 37.4219983,
    //   longitude: -122.084,
    //   radius: 50, // ✅ Keep radius small (50m)
    //   notifyOnEntry: true, // ✅ Ensure ENTRY notifications are enabled
    //   notifyOnExit: true,  // ✅ Ensure EXIT notifications are enabled
    //   notifyOnDwell: false, // 🚫 Disable dwell to prevent delays
    //   loiteringDelay: 0, // ✅ Remove delay before triggering re-entry
    // ));

  }




  void showNotification(String status, String geofenceName) async {
    var androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Geofence Alert',
      'You have $status the geofence: $geofenceName',
      notificationDetails,
    );
  }

  void showInAppAlert(String status, String geofenceName) {
    final BuildContext? context = MyApp.navigatorKey.currentState?.overlay?.context;

    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Geofence Alert'),
          content: Text('You have $status the geofence: $geofenceName'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  void saveMovementHistory(bg.GeofenceEvent event) async {
    var box = await Hive.openBox('movement_history');

    box.add({
      'timestamp': DateTime.now().toString(),
      'lat': event.location?.coords.latitude,
      'lng': event.location?.coords.longitude,
      'status': event.action == 'ENTER' ? 'Inside' : 'Outside',
    });

    print("📍 Movement history updated: You are now ${event.action == 'ENTER' ? 'Inside' : 'Outside'} ${event.identifier}");
  }
  void debugTriggerGeofenceEvent() {
    String status = 'Exited';
    String geofenceName = 'Test Geofence';

    showNotification(status, geofenceName);
    showInAppAlert(status, geofenceName);

    print("🚀 Debug Trigger: User has $status $geofenceName");
  }



}
