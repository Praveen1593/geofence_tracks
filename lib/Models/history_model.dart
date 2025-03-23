import 'package:hive/hive.dart';

part 'history_model.g.dart'; // Required for Hive TypeAdapter

@HiveType(typeId: 1) // Unique type ID for Hive
class MovementHistory {
  @HiveField(0)
  final String timestamp;

  @HiveField(1)
  final double lat;

  @HiveField(2)
  final double lng;

  @HiveField(3)
  final String status;

  MovementHistory({
    required this.timestamp,
    required this.lat,
    required this.lng,
    required this.status,
  });

  /// Convert from Map (used when retrieving from Hive)
  factory MovementHistory.fromMap(Map<dynamic, dynamic> map) {
    return MovementHistory(
      timestamp: map['timestamp'],
      lat: map['lat'] as double,
      lng: map['lng'] as double,
      status: map['status'],
    );
  }

  /// Convert to Map (used when saving to Hive)
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'lat': lat,
      'lng': lng,
      'status': status,
    };
  }
}
