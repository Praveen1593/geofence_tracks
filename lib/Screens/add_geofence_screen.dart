import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Constants/colors.dart';
import '../Controllers/addgeofence_controller.dart';
import '../Models/geofence.dart';

class NewAddGeofenceScreen extends StatelessWidget {
  final Geofence? editGeofence;
  final int? index;
  final AddGeofenceController geofenceCtr = Get.put(AddGeofenceController());

  NewAddGeofenceScreen({this.editGeofence, this.index});

  @override
  Widget build(BuildContext context) {
    if (editGeofence != null) {
      geofenceCtr.titleController.text = editGeofence!.title;
      geofenceCtr.radius.value = editGeofence!.radius;
      geofenceCtr.selectedLocation.value = LatLng(editGeofence!.lat, editGeofence!.lng);
    }
    else {
      geofenceCtr.titleController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(editGeofence != null ? 'Edit Geofence' : 'Add Geofence', style: TextStyle(color: Colors.white)),
        backgroundColor: lightOrange,
        elevation: 4,
      ),
      body: Obx(() => geofenceCtr.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      geofenceCtr.isEditing.value ? "Edit Geofence" : "Add New Geofence",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: geofenceCtr.titleController,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Geofence Title',
                        labelStyle: TextStyle(fontSize: 14, color: Colors.black54),
                        prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        errorText: geofenceCtr.titleError.value,
                      ),
                    ),
                    SizedBox(height: 15),
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Radius: ${geofenceCtr.radius.toInt()} meters",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        Text(
                          "${geofenceCtr.radius.toInt()} m",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueAccent),
                        ),
                      ],
                    )),
                    Obx(() => Slider(
                      min: 50,
                      max: 500,
                      value: geofenceCtr.radius.value,
                      onChanged: (value) => geofenceCtr.radius.value = value,
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.blue[100],
                    )),
                  ],
                ),
              ),
            ),
          ),

          // Google Map Section
          Expanded(
            child: Stack(
              children: [
                Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: geofenceCtr.selectedLocation.value ?? LatLng(0, 0),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) => geofenceCtr.mapController = controller,
                    onTap: (LatLng pos) => geofenceCtr.updateSelectedLocation(pos),
                    markers: {
                      if (geofenceCtr.selectedLocation.value != null)
                        Marker(
                          markerId: MarkerId('selected'),
                          position: geofenceCtr.selectedLocation.value!,
                        ),
                    },
                    circles: {
                      if (geofenceCtr.selectedLocation.value != null)
                        Circle(
                          circleId: CircleId('geofence_radius'),
                          center: geofenceCtr.selectedLocation.value!,
                          radius: geofenceCtr.radius.value,
                          fillColor: Colors.blueAccent.withOpacity(0.3),
                          strokeWidth: 2,
                          strokeColor: Colors.blueAccent,
                        ),
                    },
                  ),
                )),
                Positioned(
                  bottom: 100,
                  right: 5,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    onPressed: geofenceCtr.getCurrentLocation,
                    child: Icon(Icons.my_location, color: Colors.blueAccent, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 5,
                ),
                onPressed: () {
                  if (geofenceCtr.isEditing.value) {
                    print("Editing Geofence: ${geofenceCtr.titleController.text}");
                  } else {
                    geofenceCtr.saveGeofence(editGeofence: editGeofence, index: index);
                    print("Adding New Geofence: ${geofenceCtr.titleController.text}");
                  }
                  //geofenceCtr.resetFields();
                },
                child: Text(
                  'Save Geofence',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      )),

    );
  }
}

