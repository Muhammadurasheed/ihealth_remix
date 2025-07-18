import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ihealth_naija_test_version/controllers/diagnosis_controller.dart';
import 'package:ihealth_naija_test_version/models/image_diagnosis_model.dart';
import '../services/dio_client.dart';

enum ImageDiagnosisStatus { initial, loading, success, error }

class ImageDiagnosisState {
  final ImageDiagnosisStatus status;
  final ImageDiagnosisModel? result;
  final String? errorMessage;

  ImageDiagnosisState({
    this.status = ImageDiagnosisStatus.initial,
    this.result,
    this.errorMessage,
  });

  ImageDiagnosisState copyWith({
    ImageDiagnosisStatus? status,
    ImageDiagnosisModel? result,
    String? errorMessage,
  }) {
    return ImageDiagnosisState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ImageDiagnosisNotifier extends StateNotifier<ImageDiagnosisState> {
  final DiagnosisController _controller;

  ImageDiagnosisNotifier(this._controller) : super(ImageDiagnosisState());

  Future<void> analyzeImage(File imageFile) async {
    state = state.copyWith(status: ImageDiagnosisStatus.loading);

    try {
      final diagnosis = await _controller.diagnosisFromImage(imageFile);
      state = state.copyWith(
        status: ImageDiagnosisStatus.success,
        result: diagnosis,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImageDiagnosisStatus.error,
        errorMessage: 'Failed to analyze image: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = ImageDiagnosisState();
  }
}

final imageDiagnosisControllerProvider = Provider<DiagnosisController>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiagnosisController(dioClient);
});

final imageDiagnosisProvider =
    StateNotifierProvider<ImageDiagnosisNotifier, ImageDiagnosisState>((ref) {
  final controller = ref.watch(imageDiagnosisControllerProvider);
  return ImageDiagnosisNotifier(controller);
});
