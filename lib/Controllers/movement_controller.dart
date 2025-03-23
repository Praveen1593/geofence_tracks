import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Models/history_model.dart';

class MovementHistoryController extends GetxController {
  RxList<MovementHistory> movementHistory = <MovementHistory>[].obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  Rx<LatLng> initialLocation = LatLng(11.004556, 76.961632).obs;
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    loadMovementHistory();
  }

  /// Load movement history from Hive
  Future<void> loadMovementHistory() async {
    var box = await Hive.openBox('movement_history');
    var historyList = box.values.map((entry) => MovementHistory.fromMap(entry)).toList();

    if (historyList.isNotEmpty) {
      movementHistory.assignAll(historyList);
      initialLocation.value = LatLng(
        movementHistory.last.lat,
        movementHistory.last.lng,
      );

      // Generate polyline
      polylines.value = {
        Polyline(
          polylineId: PolylineId('movement_route'),
          color: Colors.blueAccent,
          width: 6,
          points: movementHistory.map((entry) => LatLng(entry.lat, entry.lng)).toList(),
          patterns: [PatternItem.dash(12), PatternItem.gap(6)],
        ),
      };

      // Generate markers
      markers.value = movementHistory.map((entry) {
        return Marker(
          markerId: MarkerId(entry.timestamp),
          position: LatLng(entry.lat, entry.lng),
          infoWindow: InfoWindow(
            title: 'Location Update',
            snippet: "Status: ${entry.status} ",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            entry.status == "Inside" ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        );
      }).toSet();

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(initialLocation.value, 14),
      );
    }
  }
}
