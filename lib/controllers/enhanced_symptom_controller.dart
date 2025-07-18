
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/diagnosis_model.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/community_validation_provider.dart';
import '../main.dart';

class EnhancedSymptomController {
  /// Enhanced text submission with community validation
  Future<void> handleEnhancedTextSubmission(String text, WidgetRef ref) async {
    try {
      // Process diagnosis as before
      await ref.read(diagnosisProvider.notifier).processFullDiagnosis(text);
      
      final diagnosis = ref.read(diagnosisProvider).diagnosis;
      final explanation = ref.read(diagnosisProvider).explanation;
      final education = ref.read(diagnosisProvider).educationalContent;

      if (diagnosis != null && explanation != null && education != null) {
        // Submit for community validation if accuracy is uncertain
        if (_shouldSubmitForValidation(diagnosis)) {
          await ref.read(communityValidationProvider.notifier)
              .submitForValidation(diagnosis);
        }
        
        // Set current providers and navigate
        ref.read(currentDiagnosisProvider.notifier).state = diagnosis;
        ref.read(currentExplanationProvider.notifier).state = explanation;
        ref.read(currentEducationProvider.notifier).state = education;
        ref.read(currentScreenProvider.notifier).state = AppScreen.analyzing;
      }
    } catch (e) {
      debugPrint('❌ Enhanced text submission failed: $e');
      rethrow;
    }
  }

  /// Enhanced voice submission with real-time accuracy feedback
  Future<void> handleEnhancedVoiceSubmission(
    String transcription,
    WidgetRef ref,
  ) async {
    try {
      // Process with speech flag
      await ref.read(diagnosisProvider.notifier)
          .processFullDiagnosis(transcription, isSpeech: true);

      final diagnosis = ref.read(diagnosisProvider).diagnosis;
      final explanation = ref.read(diagnosisProvider).explanation;
      final education = ref.read(diagnosisProvider).educationalContent;

      if (diagnosis != null && explanation != null && education != null) {
        // Voice diagnoses often benefit from community validation
        // due to potential transcription/translation errors
        await ref.read(communityValidationProvider.notifier)
            .submitForValidation(diagnosis);
        
        ref.read(currentDiagnosisProvider.notifier).state = diagnosis;
        ref.read(currentExplanationProvider.notifier).state = explanation;
        ref.read(currentEducationProvider.notifier).state = education;
        ref.read(currentScreenProvider.notifier).state = AppScreen.analyzing;
      }
    } catch (e) {
      debugPrint('❌ Enhanced voice submission failed: $e');
      rethrow;
    }
  }

  /// Determine if diagnosis should be submitted for community validation
  bool _shouldSubmitForValidation(DiagnosisModel diagnosis) {
    // Submit for validation if:
    // 1. Confidence is below 85%
    // 2. Multiple conditions with similar confidence
    // 3. Severity is high
    
    if (diagnosis.conditions.isEmpty) return false;
    
    final highestConfidence = diagnosis.conditions
        .map((c) => c.confidence)
        .reduce((a, b) => a > b ? a : b);
    
    if (highestConfidence < 85) return true;
    
    if (diagnosis.severity.toLowerCase() == 'severe') return true;
    
    // Check for multiple conditions with similar confidence
    final topConditions = diagnosis.conditions
        .where((c) => c.confidence >= highestConfidence - 10)
        .length;
    
    return topConditions > 1;
  }

  /// Get real-time community insights for a diagnosis
  Future<Map<String, dynamic>> getCommunityInsights(String diagnosisId) async {
    try {
      // In real implementation, this would call your backend
      await Future.delayed(const Duration(milliseconds: 300));
      
      return {
        'similar_cases': 12,
        'community_accuracy': 87.5,
        'doctor_verified': true,
        'user_feedback': [
          'This helped me identify early symptoms',
          'Found a clinic nearby thanks to this',
          'Translation was very accurate'
        ],
        'trending_symptoms': ['headache', 'fever', 'cough'],
      };
    } catch (e) {
      debugPrint('❌ Failed to get community insights: $e');
      return {};
    }
  }
}

final enhancedSymptomControllerProvider = Provider(
  (ref) => EnhancedSymptomController(),
);
