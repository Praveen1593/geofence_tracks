// import 'package:hive/hive.dart';
//
// part 'geofence.g.dart';
//
// @HiveType(typeId: 1)
// class Geofence extends HiveObject {
//   @HiveField(0)
//   String title;
//
//   @HiveField(1)
//   double lat; // ✅ Ensure these are double
//
//   @HiveField(2)
//   double lng;
//
//   @HiveField(3)
//   double radius;
//
//   @HiveField(4)
//   String status;
//
//   Geofence({
//     required this.title,
//     required this.lat,
//     required this.lng,
//     required this.radius,
//     required this.status,
//   });
//
//   // Convert from Map (ensure proper parsing)
//   factory Geofence.fromMap(Map<dynamic, dynamic> map) {
//     return Geofence(
//       title: map['title'] ?? '',
//       lat: double.tryParse(map['lat'].toString()) ?? 0.0,
//       lng: double.tryParse(map['lng'].toString()) ?? 0.0,
//       radius: double.tryParse(map['radius'].toString()) ?? 100.0,
//       status: map['status'] ?? 'Outside',
//     );
//   }
//
//   // Convert to Map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'lat': lat,
//       'lng': lng,
//       'radius': radius,
//       'status': status,
//     };
//   }
// }
import 'package:hive/hive.dart';

part 'geofence.g.dart';

@HiveType(typeId: 1)
class Geofence extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double lat;

  @HiveField(2)
  double lng;

  @HiveField(3)
  double radius;

  @HiveField(4)
  String status;

  Geofence({
    required this.title,
    required this.lat,
    required this.lng,
    required this.radius,
    required this.status,
  });
}
