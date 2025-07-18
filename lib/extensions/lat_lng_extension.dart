import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LatLngExtension on LatLng {
  LatLng toOffset(double latOffset, double lngOffset) {
    return LatLng(latitude + latOffset, longitude + lngOffset);
  }
}