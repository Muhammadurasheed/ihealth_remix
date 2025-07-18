import 'package:dio/dio.dart';
import '../services/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EducationController {
  final DioClient _dioClient;

  EducationController(this._dioClient);

  Future<Response> getConditionContent({required String condition}) async {
    try {
      return await _dioClient.get('/api/education/content/$condition');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> generateVideo({
    required String condition,
    required String prompt,
  }) async {
    try {
      return await _dioClient.post(
        '/api/education/generate-video',
        data: {
          'condition': condition,
          'prompt': prompt,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}



final educationControllerProvider = Provider<EducationController>((ref) {
  return EducationController(ref.read(dioClientProvider));
});
