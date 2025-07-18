import 'package:latlong2/latlong.dart';

class Clinic {
  final String id;
  final String name;
  final String address;
  final dynamic latitude;
  final dynamic longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? type;
  final String? distance;
  final double? rating;
  final String? openingHours;

  LatLng get latLng {
    // Convert latitude/longitude to doubles
    double lat = latitude is String ? double.tryParse(latitude) ?? 0.0 : (latitude ?? 0.0).toDouble();
    double lng = longitude is String ? double.tryParse(longitude) ?? 0.0 : (longitude ?? 0.0).toDouble();
    return LatLng(lat, lng);
  }

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    this.type,
    this.distance,
    this.rating,
    this.openingHours,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      type: json['type'],
      distance: json['distance'],
      rating: json['rating']?.toDouble(),
      openingHours: json['openingHours'],
    );
  }
}