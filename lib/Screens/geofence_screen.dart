import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/colors.dart';
import '../Controllers/addgeofence_controller.dart';
import '../Models/geofence.dart';
import 'add_geofence_screen.dart';
import 'movement_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GeofenceScreen extends StatefulWidget {
  @override
  _GeofenceScreenState createState() => _GeofenceScreenState();
}
class _GeofenceScreenState extends State<GeofenceScreen> {
  final AddGeofenceController geofenceCtr = Get.put(AddGeofenceController());

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Geofences',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: lightOrange,
        elevation: 4,
      ),
      body: Obx(() {
        if (geofenceCtr.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: geofenceCtr.geofences.isEmpty
                  ? Center(
                child: Text(
                  "No geofences added yet!",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              )
                  : Obx(() =>ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: geofenceCtr.geofences.length,
                itemBuilder: (context, index) {
                  Geofence geofence = geofenceCtr.geofences[index];
                  bool isInside = geofence.status == 'Inside';

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isInside ? Colors.green[50] : Colors.red[50],

                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: isInside ? Colors.green : Colors.red, // Highlighted border color
                        width: 1.0, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50, // Adjust size as needed
                                height: 50,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage('assets/geofence.jpg'), // Replace with your image path
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  geofence.title,
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: SizedBox(
                                  width: 100,
                                  child: Chip(
                                    label: Text(
                                      geofence.status.toString() ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isInside ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    backgroundColor: isInside ? Colors.green[100] : Colors.red[100],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Lat: ${geofence.lat}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Lng: ${geofence.lng}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Radius: ${geofence.radius}m',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: lightOrange,size: 25,),
                                  onPressed: () {
                                    Get.to(() => NewAddGeofenceScreen(editGeofence: geofenceCtr.geofences[index], index: index))
                                        ?.then((_) => geofenceCtr.loadGeofences());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool? confirmed = await Get.dialog<bool>(
                                      AlertDialog(
                                        title: Text("Delete Geofence"),
                                        content: Text("Are you sure you want to delete this geofence?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(result: false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.back(result: true),
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await geofenceCtr.deleteGeofence(index);
                                      Get.snackbar(
                                        "Success",
                                        "Geofence deleted successfully",
                                        backgroundColor: lightOrange,
                                        colorText: Colors.white,

                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ),
        Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.history, color: Colors.white),
                  label: Text("Movement History", style: GoogleFonts.poppins(color: Colors.white)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MovementHistoryScreen()),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightOrange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Add Geofence", style: GoogleFonts.poppins(color: Colors.white)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewAddGeofenceScreen()),
                  ).then((_) => geofenceCtr.loadGeofences()),

                ),


              ],
            ),
          ),
          ],
        );
      }),
    );
  }
}