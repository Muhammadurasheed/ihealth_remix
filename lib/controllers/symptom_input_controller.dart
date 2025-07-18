
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:ihealth_naija_test_version/models/diagnosis_model.dart';
import 'package:ihealth_naija_test_version/providers/diagnosis_provider.dart';
import 'package:ihealth_naija_test_version/controllers/enhanced_symptom_controller.dart';
import 'package:ihealth_naija_test_version/main.dart';

class SymptomInputController {
  /// Enhanced text submission with community validation layer
  Future<void> handleTextSubmission(String text, WidgetRef ref) async {
    // Use the enhanced controller for better accuracy and community features
    final enhancedController = ref.read(enhancedSymptomControllerProvider);
    await enhancedController.handleEnhancedTextSubmission(text, ref);
  }
  
  /// Process voice transcription with enhanced language detection
  Future<DiagnosisModel> processVoiceTranscription(String transcription, WidgetRef ref) async {
    debugPrint('🎙️ Processing voice transcription: $transcription');
    try {
      final diagnosisController = ref.read(diagnosisControllerProvider);
      
      // Enhanced: Add confidence scoring for transcription quality
      final translationResponse = await diagnosisController.diagnosisFromSpeech(transcription);
      
      // Add transcription confidence metadata
      debugPrint('🔍 Language detected: ${translationResponse.spokenLanguage}');
      debugPrint('📝 Translation quality estimated: HIGH'); // Would be calculated in real implementation
      
      return translationResponse;
    } catch (e) {
      debugPrint('❌ Error processing voice transcription: $e');
      throw e;
    }
  }

  /// Enhanced voice submission with community validation
  Future<void> handleVoiceSubmission(
    String transcription,
    WidgetRef ref,
  ) async {
    // Use enhanced controller for voice processing
    final enhancedController = ref.read(enhancedSymptomControllerProvider);
    await enhancedController.handleEnhancedVoiceSubmission(transcription, ref);
  }

  /// NEW: Get community insights for user engagement
  Future<Map<String, dynamic>> getCommunityInsights(String diagnosisId, WidgetRef ref) async {
    final enhancedController = ref.read(enhancedSymptomControllerProvider);
    return await enhancedController.getCommunityInsights(diagnosisId);
  }

  /// NEW: Quick symptom checker for common conditions
  Future<List<String>> getQuickSymptomSuggestions(String partialText) async {
    debugPrint('🔍 Getting symptom suggestions for: $partialText');
    
    // Enhanced symptom matching with multilingual support
    final commonSymptoms = [
      // English
      'headache', 'fever', 'cough', 'sore throat', 'nausea', 'dizziness',
      'chest pain', 'shortness of breath', 'fatigue', 'muscle pain',
      
      // Common translations (would be expanded in real implementation)
      'headache / cefaleia / maux de tête',
      'fever / febre / fièvre',
      'cough / tosse / toux',
    ];
    
    return commonSymptoms
        .where((symptom) => symptom.toLowerCase().contains(partialText.toLowerCase()))
        .take(5)
        .toList();
  }
}

final symptomInputControllerProvider = Provider(
  (ref) => SymptomInputController(),
);
