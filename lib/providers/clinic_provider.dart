import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/clinic_controller.dart';
import '../models/clinic.dart';

class ClinicState {
  final bool isLoading;
  final String? errorMessage;
  final List<Clinic> clinics;

  ClinicState({
    this.isLoading = false,
    this.errorMessage,
    this.clinics = const [],
  });

  ClinicState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Clinic>? clinics,
  }) {
    return ClinicState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      clinics: clinics ?? this.clinics,
    );
  }
}

class ClinicNotifier extends StateNotifier<ClinicState> {
  final ClinicController _clinicController;

  ClinicNotifier(this._clinicController) : super(ClinicState());

  Future<void> searchClinics({
    required double latitude,
    required double longitude,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await _clinicController.searchClinics(
        latitude: latitude,
        longitude: longitude,
      );
      
      if (response.statusCode == 200) {
        final clinicsData = response.data['clinics'] as List<dynamic>;
        final clinics = clinicsData.map((data) => Clinic.fromJson(data)).toList();
        
        state = state.copyWith(clinics: clinics, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to find clinics',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void clearClinics() {
    state = ClinicState();
  }
}

final clinicProvider = StateNotifierProvider<ClinicNotifier, ClinicState>((ref) {
  return ClinicNotifier(ref.read(clinicControllerProvider));
});