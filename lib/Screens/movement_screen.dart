import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../Constants/colors.dart';
import '../Controllers/movement_controller.dart';


class MovementHistoryScreen extends StatelessWidget {
  final MovementHistoryController controller = Get.put(MovementHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Movement History', style: TextStyle(color: Colors.white)),
        backgroundColor: lightOrange,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Map Display
          Expanded(
            flex: 1,
            child: Obx(() => ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.initialLocation.value,
                  zoom: 14,
                ),
                polylines: controller.polylines,
                markers: controller.markers,
                onMapCreated: (mapController) {
                  controller.mapController = mapController;
                  controller.loadMovementHistory();
                },
              ),
            )),
          ),

          // Movement History List
          Expanded(
            flex: 1,
            child: Obx(() => controller.movementHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(BoxIcons.bx_history, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No movement history available.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: controller.movementHistory.length,
              itemBuilder: (context, index) {
                var entry = controller.movementHistory[index];
                bool isInside = entry.status == "Inside";
                String formattedTime = DateFormat('MMM dd, hh:mm a').format(DateTime.parse(entry.timestamp));

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isInside ? Colors.green.shade200 : Colors.red.shade200,
                          child: Icon(
                            isInside ? BoxIcons.bx_check_circle : BoxIcons.bx_error_circle,
                            color: isInside ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formattedTime, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Lat: ${entry.lat}', style: TextStyle(color: Colors.grey)),
                              Text('Lng: ${entry.lng}', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(entry.status, style: TextStyle(color: isInside ? Colors.green.shade900 : Colors.red.shade900)),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
