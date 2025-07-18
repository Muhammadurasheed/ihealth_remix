import 'package:dio/dio.dart';
import '../services/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClinicController {
  final DioClient _dioClient;

  ClinicController(this._dioClient);

  Future<Response> searchClinics({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _dioClient.get(
        '/api/clinics/search',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

final clinicControllerProvider = Provider<ClinicController>((ref) {
  return ClinicController(ref.read(dioClientProvider));
});
