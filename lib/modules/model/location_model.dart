// Model untuk menampung data dari OpenStreetMap Nominatim
import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 0) // Ini adalah ID untuk class Location
class Location extends HiveObject {
  @HiveField(0) // Index 0
  final int placeId;

  @HiveField(1) // Index 1
  final String displayName;

  @HiveField(2) // Index 2
  final String lat;

  @HiveField(3) // Index 3
  final String lon;

  Location({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      placeId: json['place_id'] ?? 0,
      displayName: json['display_name'] ?? 'Alamat tidak ditemukan',
      lat: json['lat'] ?? '0.0',
      lon: json['lon'] ?? '0.0',
    );
  }
}

