import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../Models/geofence.dart';
import '../Services/notification.dart';

class AddGeofenceController extends GetxController {
  var titleController = TextEditingController();
  var isLoading = false.obs;
  var selectedLocation = Rxn<LatLng>();
  var radius = 100.0.obs;
  var titleError = RxnString();
  var geofences = <Geofence>[].obs;
  GoogleMapController? mapController;
  String lastStatus = "Unknown";
  var geofenceStatus = "".obs;
  var isEditing = false.obs;
  /// Initialize the controller
  @override
  void onInit() {
    super.onInit();
    loadGeofences();
    getCurrentLocation();
    selectedLocation.listen((_) {
      checkGeofenceStatusAndNotify();
    });
    // Start real-time tracking of the user's location
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update when moving 5 meters
      ),
    ).listen((Position position) {
      selectedLocation.value = LatLng(position.latitude, position.longitude);
      checkGeofenceStatusAndNotify();
    });
  }
  // Function to set values when editing


  void updateSelectedLocation(LatLng newLocation) {
    selectedLocation.value = newLocation;
    updateGeofenceStatus();
  }
  void updateGeofenceStatus() {
    debounce(radius, (_) {
      // Check geofence condition based on new radius & location
      geofenceStatus.value = checkGeofenceUpdate();
    }, time: Duration(milliseconds: 500)); // Debounce for efficiency
  }
  String checkGeofenceUpdate() {
    if (selectedLocation.value == null) return "No Location";
    // Add logic for checking geofence status based on radius
    return "Inside Geofence"; // Example
  }

  Future<void> checkGeofenceStatusAndNotify() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      var geofenceBox = await Hive.openBox<Geofence>('geofences');
      var historyBox = await Hive.openBox('movement_history');

      for (int i = 0; i < geofences.length; i++) {
        Geofence geofence = geofences[i];
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          geofence.lat,
          geofence.lng,
        );

        String newStatus = (distance <= geofence.radius) ? 'Inside' : 'Outside';

        if (geofence.status != newStatus) {
          geofences[i] = Geofence(
            title: geofence.title,
            lat: geofence.lat,
            lng: geofence.lng,
            radius: geofence.radius,
            status: newStatus,
          );

          await geofenceBox.putAt(i, geofences[i]);

          // Save movement history with geofence title
          await historyBox.add({
            'timestamp': DateTime.now().toString(),
            'lat': position.latitude,
            'lng': position.longitude,
            'status': newStatus,
            'geofence': geofence.title,  // Store geofence name
          });

          await NotificationService().showNotification(
            "Geofence Alert",
            "You are now $newStatus ${geofence.title}",
          );
        }
      }

      geofences.refresh(); // Refresh UI after updating
    } catch (e) {
      print("Error checking geofence status: $e");
    }
  }
  /// Load existing geofences from Hive
  void loadGeofences() async {
    isLoading(true);
    var box = await Hive.openBox<Geofence>('geofences');
    geofences.value = box.values.toList();
    isLoading(false);
  }
  Future<void> deleteGeofence(int index) async {
    var box = Hive.box<Geofence>('geofences');
    await box.deleteAt(index);
    geofences.removeAt(index); // Remove from the observable list.
    geofences.refresh(); // Refresh the list.
  }

  /// Get the user's current location and set it as `selectedLocation`
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      selectedLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Save or update a geofence in Hive
  Future<void> saveGeofence({Geofence? editGeofence, int? index}) async {
    titleError.value = titleController.text.isEmpty ? "Please enter the title" : null;
    if (titleError.value != null || selectedLocation.value == null) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      selectedLocation!.value!.latitude,
      selectedLocation!.value!.longitude,
    );

    String newStatus = (distance <= radius.value) ? "Inside" : "Outside";
    var box = Hive.box<Geofence>('geofences');

    Geofence newGeofence = Geofence(
      title: titleController.text,
      lat: selectedLocation!.value!.latitude,
      lng: selectedLocation!.value!.longitude,
      radius: radius.value,
      status: newStatus,
    );

    if (editGeofence != null && index != null) {
      await box.putAt(index, newGeofence);
      geofences[index] = newGeofence;
    } else {
      await box.add(newGeofence);
      geofences.add(newGeofence);
    }

    Get.back(result: true);
  }

  /// Check geofence status based on current position
  Future<void> checkGeofenceStatusForPosition(Position position) async {
    try {
      print("Checking Geofence Status: ${position.latitude}, ${position.longitude}");
      var historyBox = Hive.box('movement_history');
      var geofenceBox = Hive.box<Geofence>('geofences');

      List<Geofence> updatedGeofences = [];

      for (var geofence in geofences) {
        double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, geofence.lat, geofence.lng,
        );
        String newStatus = (distance <= geofence.radius) ? 'Inside' : 'Outside';

        if (geofence.status != newStatus) {
          Geofence updatedGeofence = Geofence(
            title: geofence.title,
            lat: geofence.lat,
            lng: geofence.lng,
            radius: geofence.radius,
            status: newStatus,
          );
          updatedGeofences.add(updatedGeofence);

          await NotificationService().showNotification(
            "Geofence Alert",
            "You are 2now $newStatus ${geofence.title}",
          );

          await historyBox.add({
            'timestamp': DateTime.now().toString(),
            'lat': position.latitude,
            'lng': position.longitude,
            'status': newStatus,
          });
        }
      }

      for (var updatedGeofence in updatedGeofences) {
        int index = geofences.indexWhere((g) => g.title == updatedGeofence.title);
        if (index != -1) {
          await geofenceBox.putAt(index, updatedGeofence);
          geofences[index] = updatedGeofence;
        }
      }
    } catch (e) {
      print("Error checking geofence status: $e");
    }
  }
}
