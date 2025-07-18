import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/diagnosis_model.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  // Cache for frequently accessed data
  List<DiagnosisModel>? _diagnosesCache;

  StorageService(this._secureStorage);

  // Key for storing diagnoses list
  static const String _diagnosesKey = 'diagnoses_history';

  // Save a diagnosis to history
  // In your StorageService class
  Future<void> saveDiagnosis(DiagnosisModel diagnosis) async {
    try {
      // Get existing diagnoses
      final diagnoses = await getDiagnoses();

      // Add new diagnosis
      diagnoses.add(diagnosis);

      // Update cache
      _diagnosesCache = diagnoses;

      // Convert diagnoses to JSON
      final jsonList =
          diagnoses.map((d) {
            try {
              final json = d.toJson();
              final encoded = jsonEncode(json);
              return encoded;
            } catch (e) {
              print('Error encoding diagnosis: $e');
              print('Diagnosis data: ${d.toJson()}');
              rethrow;
            }
          }).toList();

      // Save to storage
      await _secureStorage.write(
        key: _diagnosesKey,
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      print('Error saving diagnosis: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get all diagnoses from history
  Future<List<DiagnosisModel>> getDiagnoses() async {
    try {
      // Return from cache if available
      if (_diagnosesCache != null) {
        return _diagnosesCache!;
      }

      final jsonString = await _secureStorage.read(key: _diagnosesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = List<String>.from(jsonDecode(jsonString));

      final diagnoses =
          jsonList
              .map((jsonStr) => DiagnosisModel.fromJson(jsonDecode(jsonStr)))
              .toList();

      // Update cache
      _diagnosesCache = diagnoses;

      return diagnoses;
    } catch (e) {
      print('Error getting diagnoses: $e');
      return [];
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      await _secureStorage.delete(key: _diagnosesKey);
      _diagnosesCache = null;
    } catch (e) {
      print('Error clearing history: $e');
      rethrow;
    }
  }

  // Delete a specific diagnosis by index
  Future<void> deleteDiagnosis(int index) async {
    try {
      final diagnoses = await getDiagnoses();

      if (index >= 0 && index < diagnoses.length) {
        diagnoses.removeAt(index);

        // Update cache
        _diagnosesCache = diagnoses;

        // Save to storage
        final jsonList = diagnoses.map((d) => jsonEncode(d.toJson())).toList();
        await _secureStorage.write(
          key: _diagnosesKey,
          value: jsonEncode(jsonList),
        );
      }
    } catch (e) {
      print('Error deleting diagnosis: $e');
      rethrow;
    }
  }
}

// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(const FlutterSecureStorage());
});
